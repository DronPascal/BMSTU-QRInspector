#include "startup.h"
#include <QIcon>
using namespace stefanfrings;

/**
  Entry point of the program.
*/
int main(int argc, char *argv[])
{
    setlocale(0, "RUSSIAN");
    Startup startup(argc, argv);
    return startup.exec();
}
