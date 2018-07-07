#include "screen.h"
#include "../kernel/low_level.h"

#define CTRL_CURSOR_POSITION_HIGH 0xE
#define CTRL_CURSOR_POSITION_LOW 0xF

void set_vga(char ctrl, char data)
{
    port_byte_out(REG_SCREEN_CTRL, ctrl);
    port_byte_out(REG_SCREEN_DATA, data);
}

char get_vga(char ctrl) {
    port_byte_out(REG_SCREEN_CTRL, ctrl);
    return port_byte_in(REG_SCREEN_DATA);
}

char *get_video_pointer(int col, int row)
{
    return (char *)(VIDEO_ADDRESS + (col + (row * MAX_COLS)) * 2);
}

void scroll_up(){
    for(int row = 1; row <= MAX_ROWS; row++){
        for(int col = 0; col <= MAX_COLS; col++){
            *(get_video_pointer(col, row - 1)) = *(get_video_pointer(col, row));
        }
    }
    for(int col = 0; col < MAX_COLS; col++){
        *(get_video_pointer(col, MAX_ROWS)) = ' ';
    }
}

void get_cursor_position(int* col, int* row){
    int position = 0;
    position += ((int)get_vga(CTRL_CURSOR_POSITION_HIGH)) << 8;
    position += ((int)get_vga(CTRL_CURSOR_POSITION_LOW)) & 0xff;
    *col = position % MAX_COLS;
    *row = position / MAX_COLS;
}

void set_cursor_position(int col, int row)
{
    int position = col + row * MAX_COLS;

    // Set cursor location high
    // http://www.osdever.net/FreeVGA/vga/crtcreg.htm#0E
    set_vga(CTRL_CURSOR_POSITION_HIGH, (position >> 8));

    // Set cursor location low
    // http://www.osdever.net/FreeVGA/vga/crtcreg.htm#0F
    set_vga(CTRL_CURSOR_POSITION_LOW, position & 0xff);
}

void clear_screen()
{
    for (int col = 0; col < MAX_COLS; col++)
    {
        for (int row = 0; row < MAX_ROWS; row++)
        {
            char* ptr = get_video_pointer(col, row);
            *ptr = ' ';
            *(ptr + 1) = 0x07;
        }
    }
    set_cursor_position(0, 0);
}

void print_at(char *message, int col, int row)
{
    for (int i = 0; message[i] != 0; i++)
    {
        if (col > MAX_COLS || message[i] == '\n')
        {
            col = 0;
            row++;
            if(row > MAX_ROWS) {
                scroll_up();
                row -= 1;
            }
            if(message[i] == '\n') continue;
        }
        *(get_video_pointer(col, row)) = message[i];
        col++;
    }
    set_cursor_position(col, row);
}

void print(char *message)
{
    int col, row;
    get_cursor_position(&col, &row);
    print_at(message, col, row);
}
