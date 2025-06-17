clc;
clear;
close all;
%% Setup

XLSFileName='Final_Data_02';
Tstart=91;
Tend=90+153;
Address_Station='C:\Utah State\Utah State University\Summer_2017\Paper_1\FinilizeCode01_05312017\Colorado_Station';
%Address_Result='C:\Utah State\Utah State University\Summer_2018\Paper_1\Summer_2018_Version\MatlabGeotiffResults\Colorado\EffectivePrecip';
Address_Result='C:\Utah State\Utah State University\Summer_2018\Paper_1\Summer_2018_Version\MatlabGeotiffResults\Effective_WithoutCorr';


Address_GeoTiff_2014='C:\Utah State\Utah State University\Summer_2017\Alfonso\GeoTiff_Files\Daymet_2014_Daily';
Address_GeoTiff_2015='C:\Utah State\Utah State University\Summer_2017\Alfonso\GeoTiff_Files\Daymet_2015_Daily';
Address_GeoTiff_2016='C:\Utah State\Utah State University\Summer_2017\Alfonso\GeoTiff_Files\Daymet_2016_Daily';


Address_Excel_Data='C:\Utah State\Utah State University\Spring_2017\Alfonso\Data';

Address_Excel_Summary='C:\Utah State\Utah State University\Summer_2018\Paper_1\Summer_2018_Version\Analysis';

for i=2014:2016
    %% Setup Excel Parameters
    if i==2014
        cd(Address_Excel_Summary)
        Sheet_Excel=2;
        BoundExcel_WS_ET = 'B4:B8';
        BoundExcel_C_ET  = 'D4:D8';
        BoundExcel_WS    = 'B25:B29';
        BoundExcel_C     = 'D25:D29';
        %Address_ET='C:\Utah State\Utah State University\Summer_2018\Paper_1\Summer_2018_Version\ET_Maps\Colorado\monthly et maps\monthly et maps\2014';
        Address_ET='C:\Utah State\Utah State University\Summer_2018\Paper_1\Summer_2018_Version\ET_Maps\Colorado\monthly_ET_ReProject_Snap\2014';
        cd(Address_GeoTiff_2014)
    elseif i==2015
        cd(Address_Excel_Summary)
        Sheet_Excel=2;
        BoundExcel_WS_ET = 'B9:B13';
        BoundExcel_C_ET =  'D9:D13';
        BoundExcel_WS    = 'B30:B34';
        BoundExcel_C     = 'D30:D34';
        Address_ET='C:\Utah State\Utah State University\Summer_2018\Paper_1\Summer_2018_Version\ET_Maps\Colorado\monthly_ET_ReProject_Snap\2015';

        cd(Address_GeoTiff_2015)
    else
        cd(Address_Excel_Summary)
        Sheet_Excel=2;
        BoundExcel_WS_ET = 'B14:B18';
        BoundExcel_C_ET =  'D14:D18';
        BoundExcel_WS    = 'B35:B39';
        BoundExcel_C     = 'D35:D39';
        Address_ET='C:\Utah State\Utah State University\Summer_2018\Paper_1\Summer_2018_Version\ET_Maps\Colorado\monthly_ET_ReProject_Snap\2016';

        cd(Address_GeoTiff_2016)
    end
    %% Read Daymet Geotiff
    for j=1:365
        FileName=strcat('Daymet_',num2str(i),'_Colorado_Daily_',num2str(j));       % Create the file Name
        [Matrix,R0] = geotiffread(FileName);
        info = geotiffinfo(FileName);
        Daymet_Daily(:,:,j)=Matrix;
    end
    
        %% Read METRIC Geotiff
        index=1;
    for month02=[1 5 4 3 2]
        
        cd(Address_ET)
        filePattern_ET_dat = fullfile('./', '*.tif');
        files_ET_dat= dir(filePattern_ET_dat);
        [Matrix0,R00] = geotiffread(files_ET_dat(month02).name);
        info = geotiffinfo(files_ET_dat(month02).name);
        IMresize=size(Matrix0);
        ET(:,:,index)=Matrix0;
        index=index+1;
    end
    
    
    %% Daymet (Daily to Monthly)
    for month=1:12
        if month==1
            Tstart_month=1;
            Tend_month=31;
        elseif month==2
            Tstart_month=1+31;
            Tend_month=31+28;
        elseif month==3
            Tstart_month=1+31+28;
            Tend_month=31+28+31;
        elseif month==4
            Tstart_month=1+31+28+31;
            Tend_month=31+28+31+30;
        elseif month==5
            Tstart_month=1+31+28+31+30;
            Tend_month=31+28+31+30+31;
        elseif month==6
            Tstart_month=1+31+28+31+30+31;
            Tend_month=31+28+31+30+31+30;
        elseif month==7
            Tstart_month=1+31+28+31+30+31+30;
            Tend_month=31+28+31+30+31+30+31;
        elseif month==8
            Tstart_month=1+31+28+31+30+31+30+31;
            Tend_month=31+28+31+30+31+30+31+31;
        elseif month==9
            Tstart_month=1+31+28+31+30+31+30+31+31;
            Tend_month=31+28+31+30+31+30+31+31+30;
        elseif month==10
            Tstart_month=1+31+28+31+30+31+30+31+31+30;
            Tend_month=31+28+31+30+31+30+31+31+30+31;
        elseif month==11
            Tstart_month=1+31+28+31+30+31+30+31+31+30+31;
            Tend_month=31+28+31+30+31+30+31+31+30+31+30;
        elseif month==12
            Tstart_month=1+31+28+31+30+31+30+31+31+30+31+30;
            Tend_month=31+28+31+30+31+30+31+31+30+31+30+31;
            
        end
        Size=size(Daymet_Daily);
        for k=1:Size(1,1)
            for m=1:Size(1,2)
                
                Daymet_Monthly(k,m,month)=sum(squeeze(Daymet_Daily(k,m,[Tstart_month:Tend_month])));
                
            end
        end
        
    end
    
    for month=4:8
    Daymet_Monthly_resize(:,:,month-3)=imresize(Daymet_Monthly(:,:,month),IMresize,'nearest');
    end
    
    cd(Address_Excel_Summary)
    
    Data_WS_Daily_ET= xlsread('Summary_Monthly',Sheet_Excel,BoundExcel_WS_ET);
    C_Adjust_ET     = xlsread('Summary_Monthly',Sheet_Excel,BoundExcel_C_ET); 
    C_Adjust_ET=C_Adjust_ET*0;
    Data_WS_Daily   = xlsread('Summary_Monthly',Sheet_Excel,BoundExcel_WS);
    C_Adjust        = xlsread('Summary_Monthly',Sheet_Excel,BoundExcel_C); 
    C_Adjust =C_Adjust*0;
    
    %% Statistical CalCulations
    Size=size(Daymet_Monthly_resize);
    for k=1:Size(1,1)
        for m=1:Size(1,2)
            
            Daymet_Growing_Adjusted=max(squeeze(Daymet_Monthly_resize(k,m,:))-C_Adjust(:),0);
            METRIC_Growing_Adjusted=max(squeeze(ET(k,m,:))-C_Adjust_ET(:),0);
            Guage_Monthly=Data_WS_Daily(:);
            Guage_Monthly_ET=Data_WS_Daily_ET(:);
            
            % Convert mm to inch
%             Daymet_Growing_Adjusted=Daymet_Growing_Adjusted*0.0393701;
%             METRIC_Growing_Adjusted=METRIC_Growing_Adjusted*0.0393701;
%             Guage_Monthly=Guage_Monthly*0.0393701;
%             Guage_Monthly_ET=Guage_Monthly_ET*0.0393701;
            
            D=1.9685; % inch for loamy soil medium rooting crops (50 mm)
            SF=0.531747+0.295164*D-0.057697*D^2+0.003804*D^3;
            %Sptial_Monthly_Effective=SF*(0.70917*Daymet_Growing_Adjusted.^0.82416-0.11556).*(10.^(0.2426*METRIC_Growing_Adjusted));
            %Guage_Monthly_Effective=SF*(0.70917*Guage_Monthly.^0.82416-0.11556).*(10.^(0.2426*Guage_Monthly_ET));
            Sptial_Monthly_Effective=SF*(1.253*(Daymet_Growing_Adjusted.^0.824)-2.935).*(10.^(0.001*METRIC_Growing_Adjusted));
            Guage_Monthly_Effective =SF*(1.253*(Guage_Monthly.^0.824)-2.935).*(10.^(0.001*Guage_Monthly_ET));
            % Check limits and Convert inch to mm
            
            Sptial_Monthly_Effective=min(Sptial_Monthly_Effective,Daymet_Growing_Adjusted);
            Sptial_Monthly_Effective=min(Sptial_Monthly_Effective,METRIC_Growing_Adjusted);
            %Sptial_Monthly_Effective=Sptial_Monthly_Effective*25.4;
            
            
            Guage_Monthly_Effective=min(Guage_Monthly_Effective,Guage_Monthly);
            Guage_Monthly_Effective=min(Guage_Monthly_Effective,Guage_Monthly_ET);
            
            %Guage_Monthly_Effective=Guage_Monthly_Effective*25.4;
            
            
            
            %             if sum(isnan(squeeze(ET(k,m,:))))==5
            %                 Corr_Daymet_MAE(k,m)=NaN;
            %             elseif sum(isnan(squeeze(Daymet_Monthly_resize(k,m,:))))==5
            %                 Corr_Daymet_MAE(k,m)=NaN;
            %             else
            %                 Corr_Daymet_MAE(k,m)=sum(abs(Sptial_Monthly_Effective-Guage_Monthly_Effective));
            %             end
            if ET(k,m,1)==3.4028235e+38
                Corr_Daymet_MAE(k,m)=NaN;
            elseif Daymet_Monthly_resize(k,m,1)==3.4028235e+38
                Corr_Daymet_MAE(k,m)=NaN;
            else
                Corr_Daymet_MAE(k,m)=sum(abs(Sptial_Monthly_Effective-Guage_Monthly_Effective));
            end

            
            if ET(k,m,1)==3.4028235e+38
                Sptial_Monthly_Effective_Matrix(k,m)=NaN;
            elseif Daymet_Monthly_resize(k,m,1)==3.4028235e+38
                Sptial_Monthly_Effective_Matrix(k,m)=NaN;
            elseif sum(Sptial_Monthly_Effective==Inf)>0
                Sptial_Monthly_Effective_Matrix(k,m)=NaN;
            elseif sum(Sptial_Monthly_Effective==-Inf)>0
                Sptial_Monthly_Effective_Matrix(k,m)=NaN;
            else
                Sptial_Monthly_Effective_Matrix(k,m)=nansum(Sptial_Monthly_Effective);
            end
        end
    end
  
    
    if i==2014
        cd(Address_Result)
        FileName_MAE='Daymet_2014_Colorado_Effective_SAE';

    elseif i==2015
        cd(Address_Result)
        FileName_MAE='Daymet_2015_Colorado_Effective_SAE';

    else
        cd(Address_Result)
        FileName_MAE='Daymet_2016_Colorado_Effective_SAE';

    end
    geotiffwrite(strcat(FileName_MAE),Sptial_Monthly_Effective_Matrix,R00,'GeoKeyDirectoryTag',info.GeoTIFFTags.GeoKeyDirectoryTag)

    
end

