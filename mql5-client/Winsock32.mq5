//+------------------------------------------------------------------+
//|                                                    Winsock32.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#include <SocketLib.mqh>

input string Host="127.0.0.1";  //47.107.182.109
input ushort Port=8080;
SOCKET64 client=INVALID_SOCKET64;
void OnStart()
  {
   char wsaData[]; 
   ArrayResize(wsaData,sizeof(WSAData));
   int res=WSAStartup(MAKEWORD(2,2), wsaData);
   if(res!=0) { Print("-WSAStartup failed error: "+string(res)); return; }
   client=socket(AF_INET,SOCK_STREAM,IPPROTO_TCP);
   //Print("client: ",client);
   if(client==INVALID_SOCKET64) { Print("-Create failed error: "+WSAErrorDescript(WSAGetLastError())); CloseClean(); return; }
   char ch[]; StringToCharArray(Host,ch);
   sockaddr_in addrin;
   addrin.sin_family=AF_INET;
   addrin.sin_addr.u.S_addr=inet_addr(ch);
   addrin.sin_port=htons(Port);

   ref_sockaddr ref; 
   ref.in=addrin;
   res=connect(client,ref.ref,sizeof(addrin));
   if(res==SOCKET_ERROR)
     {
      int err=WSAGetLastError();
      if(err!=WSAEISCONN) { Print("-Connect failed error: "+WSAErrorDescript(err)); CloseClean(); return; }
     }

// set to nonblocking mode
   int non_block=1;
   res=ioctlsocket(client,(int)FIONBIO,non_block);
   if(res!=NO_ERROR) { Print("ioctlsocket failed error: "+string(res)); CloseClean(); return; }

   Print("connect OK");
   string accountid = IntegerToString(AccountInfoInteger(ACCOUNT_LOGIN));
   char sbuf[] ; 
   StringToCharArray(accountid,sbuf,0,WHOLE_ARRAY,CP_ACP);
   while(true)
   {
      res = send(client,sbuf,ArraySize(sbuf),0);
      
      if(res>=0 && res<=ArraySize(sbuf)) break;
   }
   uchar rdata[];
   char rbuf[3]; int rlen=3; int rall=0; bool bNext=false;
   while(true)
     {
      res=recv(client,rbuf,rlen,0);
      
      if(res<0)
        {
         int err=WSAGetLastError();
         if(err!=WSAEWOULDBLOCK) { Print("-Receive failed error: "+string(err)+" "+WSAErrorDescript(err)); CloseClean(); return; }
        }
      else if(res==0 && rall==0) { Print("-Receive. connection closed"); break; }
      else if(res>0)  {rall+=res; ArrayCopy(rdata,rbuf,0,0,res);}

      if(res>=0 && res<rlen) break;
     }

// close socket
   CloseClean();

   printf("receive %d bytes",ArraySize(rdata));
   // take the symbol and period from the file
   string smb=CharArrayToString(rdata,0,ArraySize(rdata));
   //string tf=CharArrayToString(rdata,10,10);
   if(smb == "1") Print("YES");else Print("NO");
   
   
   
  }

void OnDeinit()
{
   Print("closeclean");
   CloseClean();
}
void CloseClean() // close socket
  {
   if(client!=INVALID_SOCKET64)
     {
      if(shutdown(client,SD_BOTH)==SOCKET_ERROR) Print("-Shutdown failed error: "+WSAErrorDescript(WSAGetLastError()));
      closesocket(client); client=INVALID_SOCKET64;
     }
   WSACleanup();
   Print("connect closed");
  }