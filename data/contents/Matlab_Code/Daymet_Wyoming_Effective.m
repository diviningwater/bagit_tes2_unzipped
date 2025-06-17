clc;
clear;
close all;
%% Setup

XLSFileName='Final_Data_02';
Tstart=91;
Tend=90+153;
Address_Station='C:\Utah State\Utah State University\Summer_2017\Paper_1\FinilizeCode01_05312017\Colorado_Station';
%Address_Result='C:\Utah State\Utah State University\Summer_2018\Paper_1\Summer_2018_Version\MatlabGeotiffResults\Colorado\EffectivePrecip';
Address_Result='C:\Utah State\Utah State University\Summer_2018\Paper_1\Summer_2018_Version\MatlabGeotiffResults\Effective_WithoutCorr\Wyoming';


Address_GeoTiff_2014='C:\Utah State\Utah State University\Summer_2017\Alfonso\GeoTiff_Files\Wyoming\Daymet_2014_Daily';
Address_GeoTiff_2015='C:\Utah State\Utah State University\Summer_2017\Alfonso\GeoTiff_Files\Wyoming\Daymet_2015_Daily';
Address_GeoTiff_2016='C:\Utah State\Utah State University\Summer_2017\Alfonso\GeoTiff_Files\Wyoming\Daymet_2016_Daily';


Address_Excel_Data='C:\Utah State\Utah State University\Spring_2017\Alfonso\Data';

Address_Excel_Summary='C:\Utah State\Utah State University\Summer_2018\Paper_1\Summer_2018_Version\Analysis';

for i=2014:2016
    %% Setup Excel Parameters
    if i==2014
        Address_ET='C:\Utah State\Utah State University\Summer_2018\Paper_1\Summer_2018_Version\ET_Maps\Wyoming_Mosiac_Extract_ReProj\2014';
        cd(Address_GeoTiff_2014)
    elseif i==2015
  
        Address_ET='C:\Utah State\Utah State University\Summer_2018\Paper_1\Summer_2018_Version\ET_Maps\Wyoming_Mosiac_Extract_ReProj\2015';
        cd(Address_GeoTiff_2015)
    else
        Address_ET='C:\Utah State\Utah State University\Summer_2018\Paper_1\Summer_2018_Version\ET_Maps\Wyoming_Mosiac_Extract_ReProj\2016';
        cd(Address_GeoTiff_2016)
    end
    %% Read Daymet Geotiff
    for j=1:365
        FileName=strcat('Daymet_',num2str(i),'_Wyoming_Daily_',num2str(j));       % Create the file Name
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
    

    
    
    %% CalCulations
    Size=size(Daymet_Monthly_resize);


for Month=1:5    
    D=1.9685; % inch for loamy soil medium rooting crops (50 mm)
    SF=0.531747+0.295164*D-0.057697*D^2+0.003804*D^3;
    Sptial_Monthly_Effective(:,:,Month)=SF*(1.253*(Daymet_Monthly_resize(:,:,Month).^0.824)-2.935).*(10.^(0.001*ET(:,:,Month)));

end   
% Change to Yearly
    Sptial_Yearly_Effective=sum(Sptial_Monthly_Effective,3);
    Daymet_Yearly_resize=sum(Daymet_Monthly_resize,3);
    ET_Yearly=sum(Daymet_Monthly_resize,3);
    
    Precentage_Yearly_Effective= Sptial_Yearly_Effective./Daymet_Yearly_resize;    
    Precentage_Yearly_Effective=min(Precentage_Yearly_Effective,1);
    Precentage_Yearly_Effective=max(Precentage_Yearly_Effective,0);
    
    if i==2014
        cd(Address_Result)
        FileName='Daymet_2014_Wym';

    elseif i==2015
        cd(Address_Result)
        FileName='Daymet_2015_Wym';

    else
        cd(Address_Result)
        FileName='Daymet_2016_Wym';

    end
    
    geotiffwrite(strcat(FileName),Daymet_Yearly_resize,R00,'GeoKeyDirectoryTag',info.GeoTIFFTags.GeoKeyDirectoryTag)
    geotiffwrite(strcat(FileName,'_Effective'),Sptial_Yearly_Effective,R00,'GeoKeyDirectoryTag',info.GeoTIFFTags.GeoKeyDirectoryTag)
    geotiffwrite(strcat('Precentage_',FileName),Precentage_Yearly_Effective,R00,'GeoKeyDirectoryTag',info.GeoTIFFTags.GeoKeyDirectoryTag)
    geotiffwrite(strcat('ET_',FileName),ET_Yearly,R00,'GeoKeyDirectoryTag',info.GeoTIFFTags.GeoKeyDirectoryTag)
end

