#include "../drivers/screen.h"

void start()
{
    clear_screen();
    char message[] = "Hello from C";
    print(message);
}