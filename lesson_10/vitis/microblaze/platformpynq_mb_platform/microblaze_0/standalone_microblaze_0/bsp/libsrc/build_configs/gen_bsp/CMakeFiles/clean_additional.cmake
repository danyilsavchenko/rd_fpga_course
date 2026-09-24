# Additional clean files
cmake_minimum_required(VERSION 3.16)

if("${CONFIG}" STREQUAL "" OR "${CONFIG}" STREQUAL "")
  file(REMOVE_RECURSE
  "/home/danyil/rd_fpga_course/lesson_10/vitis/microblaze/platformpynq_mb_platform/microblaze_0/standalone_microblaze_0/bsp/include/sleep.h"
  "/home/danyil/rd_fpga_course/lesson_10/vitis/microblaze/platformpynq_mb_platform/microblaze_0/standalone_microblaze_0/bsp/include/xiltimer.h"
  "/home/danyil/rd_fpga_course/lesson_10/vitis/microblaze/platformpynq_mb_platform/microblaze_0/standalone_microblaze_0/bsp/include/xtimer_config.h"
  "/home/danyil/rd_fpga_course/lesson_10/vitis/microblaze/platformpynq_mb_platform/microblaze_0/standalone_microblaze_0/bsp/lib/libxiltimer.a"
  )
endif()
