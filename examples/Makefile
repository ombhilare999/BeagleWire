SUBDIRS += blink_leds
SUBDIRS += bar_graph
SUBDIRS += gpio
SUBDIRS += i2c
SUBDIRS += lcd
SUBDIRS += lcd_game
SUBDIRS += pwm
SUBDIRS += spi
SUBDIRS += stepper_motor
SUBDIRS += uart
SUBDIRS += arm_blink_leds
SUBDIRS += encoder
SUBDIRS += vga
SUBDIRS += vga_pong

all: $(foreach d,$(SUBDIRS),$d/$d.bin)

%.bin:
	$(MAKE) -C $(dir $@)
