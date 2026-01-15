// bios.h - Common definitions for QuarkBIOS

#ifndef BIOS_H
#define BIOS_H

void init_gui();
void draw_background(int color);
void draw_text(int x, int y, const char* text, int color);

void init_keyboard();
char get_key();

void init_mouse();
void get_mouse_position(int* x, int* y);

void read_sector(int drive, int sector, void* buffer);

#endif // BIOS_H