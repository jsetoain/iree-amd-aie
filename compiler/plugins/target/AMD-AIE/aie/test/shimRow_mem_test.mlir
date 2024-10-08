
// RUN: iree-opt --amdaie-objectFifo-stateful-transform %s | FileCheck %s

// CHECK-LABEL:   aie.device(npu1_4col) {
// CHECK:           memref.global "public" @objfifo_cons : memref<16xi32>
// CHECK:           memref.global "public" @objfifo : memref<16xi32>
// CHECK:           %[[TILE_3_2:.*]] = aie.tile(3, 2)
// CHECK:           %[[TILE_3_0:.*]] = aie.tile(3, 0)
// CHECK:           %[[OBJFIFO_CONS_BUFF_0:.*]] = aie.buffer(%[[TILE_3_2]]) {sym_name = "objfifo_cons_buff_0"} : memref<16xi32>
// CHECK:           %[[OBJFIFO_CONS_BUFF_1:.*]] = aie.buffer(%[[TILE_3_2]]) {sym_name = "objfifo_cons_buff_1"} : memref<16xi32>
// CHECK:           %[[OBJFIFO_CONS_BUFF_2:.*]] = aie.buffer(%[[TILE_3_2]]) {sym_name = "objfifo_cons_buff_2"} : memref<16xi32>
// CHECK:           %[[OBJFIFO_CONS_PROD_LOCK:.*]] = aie.lock(%[[TILE_3_2]]) {init = 3 : i8, sym_name = "objfifo_cons_prod_lock"}
// CHECK:           %[[OBJFIFO_CONS_CONS_LOCK:.*]] = aie.lock(%[[TILE_3_2]]) {init = 0 : i8, sym_name = "objfifo_cons_cons_lock"}
// CHECK:           %[[OBJFIFO_PROD_LOCK:.*]] = aie.lock(%[[TILE_3_0]]) {init = 0 : i8, sym_name = "objfifo_prod_lock"}
// CHECK:           %[[OBJFIFO_CONS_LOCK:.*]] = aie.lock(%[[TILE_3_0]]) {init = 0 : i8, sym_name = "objfifo_cons_lock"}
// CHECK:           aie.flow(%[[TILE_3_0]], DMA : 0, %[[TILE_3_2]], DMA : 0)
// CHECK:           %[[EXT_BUFFER_IN:.*]] = aie.external_buffer {sym_name = "ext_buffer_in"} : memref<64xi32>
// CHECK:           func.func @some_work(%[[ARG0:.*]]: memref<16xi32>, %[[ARG1:.*]]: memref<16xi32>) {
// CHECK:             return
// CHECK:           }
// CHECK:           aie.shim_dma_allocation @objfifo(MM2S, 0, 3)
// CHECK:           %[[CORE_3_2:.*]] = aie.core(%[[TILE_3_2]]) {
// CHECK:             %[[C0:.*]] = arith.constant 0 : index
// CHECK:             %[[C1:.*]] = arith.constant 1 : index
// CHECK:             %[[C12:.*]] = arith.constant 12 : index
// CHECK:             aie.use_lock(%[[OBJFIFO_CONS_CONS_LOCK]], AcquireGreaterEqual, 2)
// CHECK:             func.call @some_work(%[[OBJFIFO_CONS_BUFF_0]], %[[OBJFIFO_CONS_BUFF_1]]) : (memref<16xi32>, memref<16xi32>) -> ()
// CHECK:             aie.use_lock(%[[OBJFIFO_CONS_PROD_LOCK]], Release, 1)
// CHECK:             aie.end
// CHECK:           }
// CHECK:           %[[MEM_3_2:.*]] = aie.mem(%[[TILE_3_2]]) {
// CHECK:             %[[VAL_0:.*]] = aie.dma_start(S2MM, 0, ^bb1, ^bb4)
// CHECK:           ^bb1:
// CHECK:             aie.use_lock(%[[OBJFIFO_CONS_PROD_LOCK]], AcquireGreaterEqual, 1)
// CHECK:             aie.dma_bd(%[[OBJFIFO_CONS_BUFF_0]] : memref<16xi32>) {len = 16 : i32}
// CHECK:             aie.use_lock(%[[OBJFIFO_CONS_CONS_LOCK]], Release, 1)
// CHECK:             aie.next_bd ^bb2
// CHECK:           ^bb2:
// CHECK:             aie.use_lock(%[[OBJFIFO_CONS_PROD_LOCK]], AcquireGreaterEqual, 1)
// CHECK:             aie.dma_bd(%[[OBJFIFO_CONS_BUFF_1]] : memref<16xi32>) {len = 16 : i32}
// CHECK:             aie.use_lock(%[[OBJFIFO_CONS_CONS_LOCK]], Release, 1)
// CHECK:             aie.next_bd ^bb3
// CHECK:           ^bb3:
// CHECK:             aie.use_lock(%[[OBJFIFO_CONS_PROD_LOCK]], AcquireGreaterEqual, 1)
// CHECK:             aie.dma_bd(%[[OBJFIFO_CONS_BUFF_2]] : memref<16xi32>) {len = 16 : i32}
// CHECK:             aie.use_lock(%[[OBJFIFO_CONS_CONS_LOCK]], Release, 1)
// CHECK:             aie.next_bd ^bb1
// CHECK:           ^bb4:
// CHECK:             aie.end
// CHECK:           }
// CHECK:         }

module @shimRow_mem {
    aie.device(npu1_4col) {
        %tile32 = aie.tile(3, 2)
        %tile30 = aie.tile(3, 0)
        aie.objectfifo @objfifo (%tile30, {%tile32}, 3 : i32) : !aie.objectfifo<memref<16xi32>>
        %ext_buffer_in  = aie.external_buffer {sym_name = "ext_buffer_in"}: memref<64xi32>
        aie.objectfifo.register_external_buffers @objfifo (%tile30, {%ext_buffer_in}) : (memref<64xi32>)
        func.func @some_work(%a : memref<16xi32>, %b : memref<16xi32>) -> () {
            return
        }
        %core71 = aie.core(%tile32) {
            %c0 = arith.constant 0 : index
            %c1 = arith.constant 1 : index
            %height = arith.constant 12 : index
            %subview = aie.objectfifo.acquire @objfifo (Consume, 2) : !aie.objectfifosubview<memref<16xi32>>
            %elem0 = aie.objectfifo.subview.access %subview[0] : !aie.objectfifosubview<memref<16xi32>> -> memref<16xi32>
            %elem1 = aie.objectfifo.subview.access %subview[1] : !aie.objectfifosubview<memref<16xi32>> -> memref<16xi32>
            func.call @some_work(%elem0, %elem1) : (memref<16xi32>, memref<16xi32>) -> ()
            aie.objectfifo.release @objfifo (Consume, 1)
            aie.end
        }
    }
}
