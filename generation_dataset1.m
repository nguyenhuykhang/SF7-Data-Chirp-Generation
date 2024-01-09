clc;
clear;
close all;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Description: Add noises to raw data
% Author: Chenning Li, Hanqing Guo
% Input: Unzipped real collected chirp (raw_1: different instance[same node and code,
% different collect time])
% Output: Noisy Chirp Signal
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Add the folder to the MATLAB path
addpath('D:\Matlab nelora\matlab\utils');

% Set your onw paths
raw_data_dir='sf70/';
generated_data_dir = '/';

% load settings
Fs = param_configs(3);         % sample rate
BW = param_configs(2);         % LoRa bandwidth
SF = param_configs(1);         % LoRa spreading factor
upsamping_factor = param_configs(4);         

nsamp = Fs * 2^SF / BW; %  number of samples
raw_data_list=scan_dir(raw_data_dir); %  list of files in the specified raw data directory.
n_raw_data_list=length(raw_data_list);


feature_dir = [generated_data_dir,'sf7_125k/'];
if ~exist(feature_dir,'dir')
    mkdir(feature_dir);
end

SNR_minimal=-30;
SNR_list=[SNR_minimal:0,35];

chirp_down = Utils.gen_symbol(0,true);

for raw_data_index=1:n_raw_data_list
    raw_data_name=raw_data_list{raw_data_index};
    [pathstr,raw_data_name_whole,ext] = fileparts(raw_data_name);
    % idx 0, code 1, 0 packet_index 2, sf 3
    raw_data_name_components = strsplit(raw_data_name_whole,'_');
    test_str=raw_data_name_components{1};
    if strcmp(test_str,'demod')==1||strcmp(test_str,'pt')==1
        continue;
    end
    [~,packet_index,~] = fileparts(pathstr);
    %% generate chirp symbol with code word (between [0,2^SF))
    chirp_raw = io_read_iq(raw_data_name);
    
    %change here
    batch_index=str2num(raw_data_name_components{3});
    %chang here
    symbol_index=str2num(raw_data_name_components{1});
    
    %% conventional signal processing
    chirp_dechirp = chirp_raw .* chirp_down;
    chirp_fft_raw =(fft(chirp_dechirp, nsamp*upsamping_factor));

    % align_win_len = length(chirp_fft_raw) / (Fs/BW);   
    % chirp_fft_overlap=chirp_fft_raw(1:align_win_len)+chirp_fft_raw(end-align_win_len+1:end);
    % chirp_fft_overlap=flip(chirp_fft_overlap);
    % chirp_peak_overlap=abs(chirp_fft_overlap);
    % [pk_height_overlap,pk_index_overlap]=max(chirp_peak_overlap);

    chirp_peak_overlap=abs(chirp_abs_alias(chirp_fft_raw, Fs/BW));
    % chirp_peak_overlap = abs(chirp_comp_alias(chirp_fft_raw, Fs / BW));

    [pk_height_overlap,pk_index_overlap]=max(chirp_peak_overlap);
    code_estimated=mod(round(pk_index_overlap/upsamping_factor),2^SF);

    code_label=str2double(raw_data_name_components{2});
    code_label=mod(round(code_label),2^SF);
    for SNR=SNR_list
        if SNR ~=35
            chirp = Utils.add_noise(chirp_raw, SNR);
            SNR_index=SNR;
        else
            chirp = chirp_raw;
            SNR_index=35;
        end
        if (length(chirp)~=8*2^SF)
            continue;
        end
        %              {Code 0 } _ {SNR 0} _ {SF 7} _ {BW 125k} _ {batch_index 1} _ {Code Label 0}_ {packet_index 10}_ {symbol_index 4}.mat
        % featuredir_codeestimated_SNRindex_SF_BW_Batchindx_Codelabel_packetidx_symbolidx
        %                 0_       0_       7_125000_1_        0_        10_      4.mat
        feature_path = [feature_dir, num2str(code_estimated),'_',num2str(SNR_index),'_',num2str(SF),'_',num2str(BW),'_',num2str(batch_index),'_',num2str(code_label),'_',num2str(packet_index),'_',num2str(symbol_index),'.mat'];
        save(feature_path, 'chirp');
    end
end
