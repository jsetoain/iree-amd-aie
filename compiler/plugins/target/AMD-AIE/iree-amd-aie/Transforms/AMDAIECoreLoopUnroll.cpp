// Copyright 2024 The IREE Authors
//
// Licensed under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception

#include <numeric>

#include "iree-amd-aie/IR/AMDAIEOps.h"
#include "iree-amd-aie/Transforms/Passes.h"
#include "iree-amd-aie/Transforms/Transforms.h"
#include "llvm/ADT/DenseSet.h"
#include "llvm/Support/MathExtras.h"
#include "mlir/Dialect/SCF/Transforms/Transforms.h"
#include "mlir/Dialect/SCF/Utils/Utils.h"

#define DEBUG_TYPE "iree-amdaie-core-loop-unroll"

namespace mlir::iree_compiler::AMDAIE {

/// Unroll the scf.for loops inside the core operations based on the depths of
/// the acquired objFifos.
LogicalResult coreLoopUnroll(RewriterBase &rewriter, AMDAIE::CoreOp coreOp) {
  WalkResult res = coreOp.walk([&](scf::ForOp forOp) {
    llvm::SmallDenseSet<unsigned> depths;
    for (auto acqOp :
         forOp.getBody()->getOps<AMDAIE::LogicalObjectFifoAcquire>()) {
      auto stridedOp = dyn_cast_if_present<DoublyStridedCopyOpInterface>(
          acqOp.getDma().getDefiningOp());
      if (!stridedOp) {
        acqOp.emitOpError()
            << "should operate on a doubly strided copy operation for core "
               "loop unrolling to behave correctly";
        return WalkResult::interrupt();
      }
      auto logicalObjFifo =
          acqOp.getPort() == LogicalObjectFifoPort::Consume
              ? dyn_cast_if_present<AMDAIE::LogicalObjectFifoFromMemrefOp>(
                    stridedOp.getTarget().getDefiningOp())
              : dyn_cast_if_present<AMDAIE::LogicalObjectFifoFromMemrefOp>(
                    stridedOp.getSource().getDefiningOp());
      depths.insert(
          cast<LogicalObjectFifoType>(logicalObjFifo.getType()).getDepth());
    }
    int unrollFactor =
        std::accumulate(depths.begin(), depths.end(), 1, std::lcm<int, int>);
    if (unrollFactor > 1 &&
        failed(mlir::loopUnrollByFactor(forOp, unrollFactor))) {
      forOp.emitOpError() << "could not be unrolled with unrollFactor: "
                          << unrollFactor << "\n";
      return WalkResult::interrupt();
    }
    return WalkResult::advance();
  });
  if (res.wasInterrupted()) return failure();
  return success();
}

namespace {

struct AMDAIECoreLoopUnrollPass
    : public impl::AMDAIECoreLoopUnrollBase<AMDAIECoreLoopUnrollPass> {
  void getDependentDialects(DialectRegistry &registry) const override {
    registry.insert<AMDAIEDialect>();
  }

  void runOnOperation() override {
    Operation *parentOp = getOperation();
    IRRewriter rewriter(parentOp->getContext());

    WalkResult res = parentOp->walk([&](AMDAIE::CoreOp coreOp) {
      if (failed(coreLoopUnroll(rewriter, coreOp))) {
        return WalkResult::interrupt();
      }
      return WalkResult::advance();
    });
    if (res.wasInterrupted()) return signalPassFailure();
  }
};

}  // namespace

std::unique_ptr<Pass> createAMDAIECoreLoopUnrollPass() {
  return std::make_unique<AMDAIECoreLoopUnrollPass>();
}

}  // namespace mlir::iree_compiler::AMDAIE
