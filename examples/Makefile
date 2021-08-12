SUBDIRS += blink_leds
SUBDIRS += bar_graph
SUBDIRS += gpio
SUBDIRS += i2c
SUBDIRS += lcd
SUBDIRS += lcd_game
SUBDIRS += pwm
SUBDIRS += sdram
SUBDIRS += sdram_litedram
SUBDIRS += spi
SUBDIRS += stepper_motor
SUBDIRS += uart
SUBDIRS += arm_blink_leds
SUBDIRS += vga
SUBDIRS += vga_pong

all: $(foreach d,$(SUBDIRS),$d/$d.bin)

%.bin:
	$(MAKE) -C $(dir $@)
