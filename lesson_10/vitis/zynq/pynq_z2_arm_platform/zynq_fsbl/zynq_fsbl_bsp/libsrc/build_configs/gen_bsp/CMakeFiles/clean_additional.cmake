# Additional clean files
cmake_minimum_required(VERSION 3.16)

if("${CONFIG}" STREQUAL "" OR "${CONFIG}" STREQUAL "")
  file(REMOVE_RECURSE
  "/home/danyil/rd_fpga_course/lesson_10/vitis/zynq/pynq_z2_arm_platform/zynq_fsbl/zynq_fsbl_bsp/include/diskio.h"
  "/home/danyil/rd_fpga_course/lesson_10/vitis/zynq/pynq_z2_arm_platform/zynq_fsbl/zynq_fsbl_bsp/include/ff.h"
  "/home/danyil/rd_fpga_course/lesson_10/vitis/zynq/pynq_z2_arm_platform/zynq_fsbl/zynq_fsbl_bsp/include/ffconf.h"
  "/home/danyil/rd_fpga_course/lesson_10/vitis/zynq/pynq_z2_arm_platform/zynq_fsbl/zynq_fsbl_bsp/include/sleep.h"
  "/home/danyil/rd_fpga_course/lesson_10/vitis/zynq/pynq_z2_arm_platform/zynq_fsbl/zynq_fsbl_bsp/include/xilffs.h"
  "/home/danyil/rd_fpga_course/lesson_10/vitis/zynq/pynq_z2_arm_platform/zynq_fsbl/zynq_fsbl_bsp/include/xilffs_config.h"
  "/home/danyil/rd_fpga_course/lesson_10/vitis/zynq/pynq_z2_arm_platform/zynq_fsbl/zynq_fsbl_bsp/include/xilrsa.h"
  "/home/danyil/rd_fpga_course/lesson_10/vitis/zynq/pynq_z2_arm_platform/zynq_fsbl/zynq_fsbl_bsp/include/xiltimer.h"
  "/home/danyil/rd_fpga_course/lesson_10/vitis/zynq/pynq_z2_arm_platform/zynq_fsbl/zynq_fsbl_bsp/include/xtimer_config.h"
  "/home/danyil/rd_fpga_course/lesson_10/vitis/zynq/pynq_z2_arm_platform/zynq_fsbl/zynq_fsbl_bsp/lib/libxilffs.a"
  "/home/danyil/rd_fpga_course/lesson_10/vitis/zynq/pynq_z2_arm_platform/zynq_fsbl/zynq_fsbl_bsp/lib/libxilrsa.a"
  "/home/danyil/rd_fpga_course/lesson_10/vitis/zynq/pynq_z2_arm_platform/zynq_fsbl/zynq_fsbl_bsp/lib/libxiltimer.a"
  )
endif()
