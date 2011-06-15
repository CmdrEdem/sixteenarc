//#define sws (volatile char*) 0x00003000
//#define LEDs (char*) 0x00003010

char sws;
char LEDs;

char fila[8];

int comeco = 0;
int fim = 0;

void pushElement()
{
	fila[fim] = 'a';
	fim++;
	if(fim > 7)
	{
		fim = 0;
	}
}

void popElement()
{
	fila[comeco] = 0;
	comeco++;
	if(comeco > 7)
	{
		comeco = 0;
	}
}

void main()
{
	int i = 0;
	char mascara = 1;
	int estado = 0;

	while(1)
	{
		mascara = 1;
		if((sws & mascara) != 0)
		{
			if(estado == 0)
			{
				estado = 1;
				mascara = 2;
				if((sws & mascara) != 0)
				{
					popElement();
				}
				else
				{
					pushElement();
				}
			}
		}
		else
		{
			if(estado == 1)
			{
				estado = 0;
				mascara = 2;
				if((sws & mascara) != 0)
				{
					popElement();
				}
				else
				{
					pushElement();
				}
			}
		}
		LEDs = 0;
		for(i = 0; i<8; i++)
		{
			if(fila[i] == 'a')
			{
				LEDs++;
			}
			LEDs = LEDs << 1;
		}
	}
}