
// RUN: iree-opt --amdaie-objectFifo-stateful-transform %s | FileCheck %s

// CHECK-LABEL:   aie.device(xcve2302) {
// CHECK:           memref.global "public" @of1_cons : memref<256xi32>
// CHECK:           memref.global "public" @of1 : memref<256xi32>
// CHECK:           memref.global "public" @of0_cons : memref<256xi32>
// CHECK:           memref.global "public" @of0 : memref<256xi32>
// CHECK:           %[[TILE_1_2:.*]] = aie.tile(1, 2)
// CHECK:           %[[TILE_1_3:.*]] = aie.tile(1, 3)
// CHECK:           %[[TILE_3_3:.*]] = aie.tile(3, 3)
// CHECK:           %[[OF1_CONS_BUFF_0:.*]] = aie.buffer(%[[TILE_3_3]]) {sym_name = "of1_cons_buff_0"} : memref<256xi32>
// CHECK:           %[[OF1_CONS_BUFF_1:.*]] = aie.buffer(%[[TILE_3_3]]) {sym_name = "of1_cons_buff_1"} : memref<256xi32>
// CHECK:           %[[OF1_CONS_PROD_LOCK:.*]] = aie.lock(%[[TILE_3_3]]) {init = 2 : i8, sym_name = "of1_cons_prod_lock"}
// CHECK:           %[[OF1_CONS_CONS_LOCK:.*]] = aie.lock(%[[TILE_3_3]]) {init = 0 : i8, sym_name = "of1_cons_cons_lock"}
// CHECK:           %[[OF1_BUFF_0:.*]] = aie.buffer(%[[TILE_1_2]]) {sym_name = "of1_buff_0"} : memref<256xi32>
// CHECK:           %[[OF1_BUFF_1:.*]] = aie.buffer(%[[TILE_1_2]]) {sym_name = "of1_buff_1"} : memref<256xi32>
// CHECK:           %[[OF1_PROD_LOCK:.*]] = aie.lock(%[[TILE_1_2]]) {init = 2 : i8, sym_name = "of1_prod_lock"}
// CHECK:           %[[OF1_CONS_LOCK:.*]] = aie.lock(%[[TILE_1_2]]) {init = 0 : i8, sym_name = "of1_cons_lock"}
// CHECK:           %[[OF0_CONS_BUFF_0:.*]] = aie.buffer(%[[TILE_1_3]]) {sym_name = "of0_cons_buff_0"} : memref<256xi32>
// CHECK:           %[[OF0_CONS_BUFF_1:.*]] = aie.buffer(%[[TILE_1_3]]) {sym_name = "of0_cons_buff_1"} : memref<256xi32>
// CHECK:           %[[OF0_CONS_BUFF_2:.*]] = aie.buffer(%[[TILE_1_3]]) {sym_name = "of0_cons_buff_2"} : memref<256xi32>
// CHECK:           %[[OF0_CONS_BUFF_3:.*]] = aie.buffer(%[[TILE_1_3]]) {sym_name = "of0_cons_buff_3"} : memref<256xi32>
// CHECK:           %[[OF0_CONS_PROD_LOCK:.*]] = aie.lock(%[[TILE_1_3]]) {init = 4 : i8, sym_name = "of0_cons_prod_lock"}
// CHECK:           %[[OF0_CONS_CONS_LOCK:.*]] = aie.lock(%[[TILE_1_3]]) {init = 0 : i8, sym_name = "of0_cons_cons_lock"}
// CHECK:           %[[OF0_BUFF_0:.*]] = aie.buffer(%[[TILE_1_2]]) {sym_name = "of0_buff_0"} : memref<256xi32>
// CHECK:           %[[OF0_BUFF_1:.*]] = aie.buffer(%[[TILE_1_2]]) {sym_name = "of0_buff_1"} : memref<256xi32>
// CHECK:           %[[OF0_BUFF_2:.*]] = aie.buffer(%[[TILE_1_2]]) {sym_name = "of0_buff_2"} : memref<256xi32>
// CHECK:           %[[OF0_BUFF_3:.*]] = aie.buffer(%[[TILE_1_2]]) {sym_name = "of0_buff_3"} : memref<256xi32>
// CHECK:           %[[OF0_PROD_LOCK:.*]] = aie.lock(%[[TILE_1_2]]) {init = 4 : i8, sym_name = "of0_prod_lock"}
// CHECK:           %[[OF0_CONS_LOCK:.*]] = aie.lock(%[[TILE_1_2]]) {init = 0 : i8, sym_name = "of0_cons_lock"}
// CHECK:           aie.flow(%[[TILE_1_2]], DMA : 0, %[[TILE_1_3]], DMA : 0)
// CHECK:           aie.flow(%[[TILE_1_2]], DMA : 1, %[[TILE_3_3]], DMA : 0)
// CHECK:           %[[MEM_1_2:.*]] = aie.mem(%[[TILE_1_2]]) {
// CHECK:             %[[VAL_0:.*]] = aie.dma_start(MM2S, 0, ^bb1, ^bb5)
// CHECK:           ^bb1:
// CHECK:             aie.use_lock(%[[OF0_CONS_LOCK]], AcquireGreaterEqual, 1)
// CHECK:             aie.dma_bd(%[[OF0_BUFF_0]] : memref<256xi32>) {dimensions = #aie<bd_dim_layout_array[<size = 16, stride = 1>, <size = 16, stride = 16>, <size = 1, stride = 1>]>, len = 256 : i32}
// CHECK:             aie.use_lock(%[[OF0_PROD_LOCK]], Release, 1)
// CHECK:             aie.next_bd ^bb2
// CHECK:           ^bb2:
// CHECK:             aie.use_lock(%[[OF0_CONS_LOCK]], AcquireGreaterEqual, 1)
// CHECK:             aie.dma_bd(%[[OF0_BUFF_1]] : memref<256xi32>) {dimensions = #aie<bd_dim_layout_array[<size = 16, stride = 1>, <size = 16, stride = 16>, <size = 1, stride = 1>]>, len = 256 : i32}
// CHECK:             aie.use_lock(%[[OF0_PROD_LOCK]], Release, 1)
// CHECK:             aie.next_bd ^bb3
// CHECK:           ^bb3:
// CHECK:             aie.use_lock(%[[OF0_CONS_LOCK]], AcquireGreaterEqual, 1)
// CHECK:             aie.dma_bd(%[[OF0_BUFF_2]] : memref<256xi32>) {dimensions = #aie<bd_dim_layout_array[<size = 16, stride = 1>, <size = 16, stride = 16>, <size = 1, stride = 1>]>, len = 256 : i32}
// CHECK:             aie.use_lock(%[[OF0_PROD_LOCK]], Release, 1)
// CHECK:             aie.next_bd ^bb4
// CHECK:           ^bb4:
// CHECK:             aie.use_lock(%[[OF0_CONS_LOCK]], AcquireGreaterEqual, 1)
// CHECK:             aie.dma_bd(%[[OF0_BUFF_3]] : memref<256xi32>) {dimensions = #aie<bd_dim_layout_array[<size = 16, stride = 1>, <size = 16, stride = 16>, <size = 1, stride = 1>]>, len = 256 : i32}
// CHECK:             aie.use_lock(%[[OF0_PROD_LOCK]], Release, 1)
// CHECK:             aie.next_bd ^bb1
// CHECK:           ^bb5:
// CHECK:             %[[VAL_1:.*]] = aie.dma_start(MM2S, 1, ^bb6, ^bb8)
// CHECK:           ^bb6:
// CHECK:             aie.use_lock(%[[OF1_CONS_LOCK]], AcquireGreaterEqual, 1)
// CHECK:             aie.dma_bd(%[[OF1_BUFF_0]] : memref<256xi32>) {dimensions = #aie<bd_dim_layout_array[<size = 128, stride = 2>]>, len = 256 : i32}
// CHECK:             aie.use_lock(%[[OF1_PROD_LOCK]], Release, 1)
// CHECK:             aie.next_bd ^bb7
// CHECK:           ^bb7:
// CHECK:             aie.use_lock(%[[OF1_CONS_LOCK]], AcquireGreaterEqual, 1)
// CHECK:             aie.dma_bd(%[[OF1_BUFF_1]] : memref<256xi32>) {dimensions = #aie<bd_dim_layout_array[<size = 128, stride = 2>]>, len = 256 : i32}
// CHECK:             aie.use_lock(%[[OF1_PROD_LOCK]], Release, 1)
// CHECK:             aie.next_bd ^bb6
// CHECK:           ^bb8:
// CHECK:             aie.end
// CHECK:           }
// CHECK:           %[[MEM_1_3:.*]] = aie.mem(%[[TILE_1_3]]) {
// CHECK:             %[[VAL_2:.*]] = aie.dma_start(S2MM, 0, ^bb1, ^bb5)
// CHECK:           ^bb1:
// CHECK:             aie.use_lock(%[[OF0_CONS_PROD_LOCK]], AcquireGreaterEqual, 1)
// CHECK:             aie.dma_bd(%[[OF0_CONS_BUFF_0]] : memref<256xi32>) {dimensions = #aie<bd_dim_layout_array[<size = 1, stride = 1>]>, len = 256 : i32}
// CHECK:             aie.use_lock(%[[OF0_CONS_CONS_LOCK]], Release, 1)
// CHECK:             aie.next_bd ^bb2
// CHECK:           ^bb2:
// CHECK:             aie.use_lock(%[[OF0_CONS_PROD_LOCK]], AcquireGreaterEqual, 1)
// CHECK:             aie.dma_bd(%[[OF0_CONS_BUFF_1]] : memref<256xi32>) {dimensions = #aie<bd_dim_layout_array[<size = 1, stride = 1>]>, len = 256 : i32}
// CHECK:             aie.use_lock(%[[OF0_CONS_CONS_LOCK]], Release, 1)
// CHECK:             aie.next_bd ^bb3
// CHECK:           ^bb3:
// CHECK:             aie.use_lock(%[[OF0_CONS_PROD_LOCK]], AcquireGreaterEqual, 1)
// CHECK:             aie.dma_bd(%[[OF0_CONS_BUFF_2]] : memref<256xi32>) {dimensions = #aie<bd_dim_layout_array[<size = 1, stride = 1>]>, len = 256 : i32}
// CHECK:             aie.use_lock(%[[OF0_CONS_CONS_LOCK]], Release, 1)
// CHECK:             aie.next_bd ^bb4
// CHECK:           ^bb4:
// CHECK:             aie.use_lock(%[[OF0_CONS_PROD_LOCK]], AcquireGreaterEqual, 1)
// CHECK:             aie.dma_bd(%[[OF0_CONS_BUFF_3]] : memref<256xi32>) {dimensions = #aie<bd_dim_layout_array[<size = 1, stride = 1>]>, len = 256 : i32}
// CHECK:             aie.use_lock(%[[OF0_CONS_CONS_LOCK]], Release, 1)
// CHECK:             aie.next_bd ^bb1
// CHECK:           ^bb5:
// CHECK:             aie.end
// CHECK:           }
// CHECK:           %[[MEM_3_3:.*]] = aie.mem(%[[TILE_3_3]]) {
// CHECK:             %[[VAL_3:.*]] = aie.dma_start(S2MM, 0, ^bb1, ^bb3)
// CHECK:           ^bb1:
// CHECK:             aie.use_lock(%[[OF1_CONS_PROD_LOCK]], AcquireGreaterEqual, 1)
// CHECK:             aie.dma_bd(%[[OF1_CONS_BUFF_0]] : memref<256xi32>) {len = 256 : i32}
// CHECK:             aie.use_lock(%[[OF1_CONS_CONS_LOCK]], Release, 1)
// CHECK:             aie.next_bd ^bb2
// CHECK:           ^bb2:
// CHECK:             aie.use_lock(%[[OF1_CONS_PROD_LOCK]], AcquireGreaterEqual, 1)
// CHECK:             aie.dma_bd(%[[OF1_CONS_BUFF_1]] : memref<256xi32>) {len = 256 : i32}
// CHECK:             aie.use_lock(%[[OF1_CONS_CONS_LOCK]], Release, 1)
// CHECK:             aie.next_bd ^bb1
// CHECK:           ^bb3:
// CHECK:             aie.end
// CHECK:           }
// CHECK:         }

module @ndDMAObjFifoAIE2 {
 aie.device(xcve2302) {
    %tile12 = aie.tile(1, 2)
    %tile13 = aie.tile(1, 3)
    %tile33 = aie.tile(3, 3)
    // Even if an objectFifo could be implemented in shared memory, as with
    // this case between two adjacent tiles, we need to use DMAs if a data
    // layout transformation with toStream and fromStream was specified.
    aie.objectfifo @of0 (%tile12 toStream [<size = 16, stride = 1>, <size = 16, stride = 16>, <size = 1, stride = 1>], // transpose
                         {%tile13 fromStream [<size = 1, stride = 1>]},
                         4 : i32) : !aie.objectfifo<memref<256xi32>>
    aie.objectfifo @of1 (%tile12 toStream [<size = 128, stride = 2>], {%tile33},
                         2 : i32) : !aie.objectfifo<memref<256xi32>>
 }
}
