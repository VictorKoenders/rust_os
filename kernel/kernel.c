void start() {
    char* video_memory = (char)0x8b000;
    *video_memory = 'X';
}