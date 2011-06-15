#define sws (volatile char*) 0x00003000
#define LEDs (char*) 0x00003010

void main()
{
	while(1)
		*LEDs = *sws;

}