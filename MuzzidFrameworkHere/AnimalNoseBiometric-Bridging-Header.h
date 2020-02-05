//
//  Use this file to import your target's public headers that you would like to expose to Swift.
//
//typedef struct _UPoint2DVec UPoint2DVec;
typedef struct _UPoint2D
{
    unsigned int x;
    unsigned int y;
} UPoint2D;

typedef struct _UPoint2DVec
{
    UPoint2D* pData;
    unsigned int nSize;
    unsigned int nCap;
} UPoint2DVec;

UPoint2DVec extractBoundary(unsigned int* label, unsigned int nWidth, unsigned int nHeight, unsigned int compIdx);
unsigned int getCC(const unsigned char* pImg, unsigned int nWidth, unsigned int nHeight,unsigned int* label, unsigned char b8nbd);
void printBoundary(unsigned int* label, unsigned int nWidth, unsigned int nHeight, UPoint2DVec ptVec);
void freeUPoint2DVec(UPoint2DVec* a);
void printLabel(unsigned int* pLabel, unsigned int nWidth, unsigned int nHeight);
void testExtractBoundary01(void);
