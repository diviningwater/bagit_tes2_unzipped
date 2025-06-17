clc;
clear;
close all;
%% Setup

XLSFileName='Final_Data_02';
Tstart=91;
Tend=90+153;
Address_Station='C:\Utah State\Utah State University\Summer_2017\Paper_1\FinilizeCode01_05312017\Colorado_Station';
Address_Result='C:\Utah State\Utah State University\Summer_2018\Paper_1\Summer_2018_Version\MatlabGeotiffResults\Colorado';


Address_GeoTiff_2014='C:\Utah State\Utah State University\Summer_2017\Alfonso\GeoTiff_Files\Daymet_2014_Daily';
Address_GeoTiff_2015='C:\Utah State\Utah State University\Summer_2017\Alfonso\GeoTiff_Files\Daymet_2015_Daily';
Address_GeoTiff_2016='C:\Utah State\Utah State University\Summer_2017\Alfonso\GeoTiff_Files\Daymet_2016_Daily';


Address_Excel_Data='C:\Utah State\Utah State University\Spring_2017\Alfonso\Data';

Address_Excel_Summary='C:\Utah State\Utah State University\Summer_2018\Paper_1\Summer_2018_Version\Analysis';

for i=2014:2016
    
    if i==2014
        cd(Address_Excel_Summary)
        Sheet_Excel=2;
        BoundExcel_WS = 'B4:B368';
        BoundExcel_C =  'D4:D368';

        cd(Address_GeoTiff_2014)
    elseif i==2015
        cd(Address_Excel_Summary)
        Sheet_Excel=2;
        BoundExcel_WS = 'B369:B733';
        BoundExcel_C =  'D369:D733';

        cd(Address_GeoTiff_2015)
    else
        cd(Address_Excel_Summary)
        Sheet_Excel=2;
        BoundExcel_WS = 'B734:B1098';
        BoundExcel_C =  'D734:D1098';

        cd(Address_GeoTiff_2016)
    end
    
    for j=1:365
        FileName=strcat('Daymet_',num2str(i),'_Colorado_Daily_',num2str(j));       % Create the file Name
        [Matrix,R0] = geotiffread(FileName);
        info = geotiffinfo(FileName);
        Daymet_Daily(:,:,j)=Matrix;
    end
    
    cd(Address_Excel_Summary)
    
    Data_WS_Daily= xlsread('Summary',Sheet_Excel,BoundExcel_WS);
    C_Adjust     = xlsread('Summary',Sheet_Excel,BoundExcel_C); 
    %% Statistical CalCulations
    Size=size(Daymet_Daily);
    for k=1:Size(1,1)
        for m=1:Size(1,2)
            
            Ps=max(squeeze(Daymet_Daily(k,m,[Tstart:Tend]))-C_Adjust(Tstart:Tend),0);
            Pg=Data_WS_Daily([Tstart:Tend]);
            Corr_Daymet_MAE(k,m)=sum(abs(Ps-Pg));

        end
    end
  
    
    if i==2014
        cd(Address_Result)
        FileName_MAE='Daymet_2014_Colorado_SAE';

    elseif i==2015
        cd(Address_Result)
        FileName_MAE='Daymet_2015_Colorado_SAE';

    else
        cd(Address_Result)
        FileName_MAE='Daymet_2016_Colorado_SAE';

    end
    geotiffwrite(strcat(FileName_MAE),Corr_Daymet_MAE,R0,'GeoKeyDirectoryTag',info.GeoTIFFTags.GeoKeyDirectoryTag)

    
end

