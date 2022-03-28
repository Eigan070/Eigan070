function readRAW
%run this function to connect and plot raw EEG data
%make sure to change portnum1 to the appropriate COM port

clear all
close all

data = zeros(100,1);    %preallocate buffer

portnum1 = 8;   %COM Port #
comPortName1 = sprintf('\\\\.\\COM%d', portnum1);

% Baud rate for use with TG_Connect() and TG_SetBaudrate().
TG_BAUD_57600 =      57600;


% Data format for use with TG_Connect() and TG_SetDataFormat().
TG_STREAM_PACKETS =     0;


% Data type that can be requested from TG_GetValue().
TG_DATA_RAW =         4;

%load thinkgear dll
loadlibrary('ThinkGear.dll');
fprintf('ThinkGear.dll loaded\n');

%get dll version
dllVersion = calllib('ThinkGear', 'TG_GetDriverVersion');
fprintf('ThinkGear DLL version: %d\n', dllVersion );


%%
% Get a connection ID handle to ThinkGear
connectionId1 = calllib('ThinkGear', 'TG_GetNewConnectionId');
if ( connectionId1 < 0 )
    error( sprintf( 'ERROR: TG_GetNewConnectionId() returned %d.\n', connectionId1 ) );
end;

% Set/open stream (raw bytes) log file for connection
errCode = calllib('ThinkGear', 'TG_SetStreamLog', connectionId1, 'streamLog.txt' );
if( errCode < 0 )
    error( sprintf( 'ERROR: TG_SetStreamLog() returned %d.\n', errCode ) );
end;

% Set/open data (ThinkGear values) log file for connection
errCode = calllib('ThinkGear', 'TG_SetDataLog', connectionId1, 'dataLog.txt' );
if( errCode < 0 )
    error( sprintf( 'ERROR: TG_SetDataLog() returned %d.\n', errCode ) );
end;

% Attempt to connect the connection ID handle to serial port "COM3"
errCode = calllib('ThinkGear', 'TG_Connect',  connectionId1,comPortName1,TG_BAUD_57600,TG_STREAM_PACKETS );
if ( errCode < 0 )
    error( sprintf( 'ERROR: TG_Connect() returned %d.\n', errCode ) );
end

fprintf( 'Connected.  Reading Packets...\n' );




%%
%record data

j = 0;
i = 0;
while (i < 2560)   %loop for 5 seconds
    if (calllib('ThinkGear','TG_ReadPackets',connectionId1,1) == 1)   %if a packet was read...
        
        if (calllib('ThinkGear','TG_GetValueStatus',connectionId1,TG_DATA_RAW) ~= 0)   %if RAW has been updated 
            j = j + 1;
            i = i + 1;
            data(j) = calllib('ThinkGear','TG_GetValue',connectionId1,TG_DATA_RAW);
        end
    end
     
    if (j == 100)
        plotRAW(data);            %plot the data, update every .5 seconds (100 points)
        j = 0;
    end
    
end

%disconnect             
calllib('ThinkGear', 'TG_FreeConnection', connectionId1 );
function plotRAW(data)
%this subfunction is used to plot EEG data

plot(data)
axis([0 100 -2000 2000])
drawnow;

%save data
csvwrite('dat01.csv',data)
dlmwrite('dat01.csv',data,'precision','%.6f');




