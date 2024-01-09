raw_data_dir='D:\Matlab nelora/matlab/sf70';
raw_data_list=scan_dir(raw_data_dir);
n_raw_data_list=length(raw_data_list);
raw_data_name_whole= '0_0_34_7_125000_1';
raw_data_name_components = strsplit(raw_data_name_whole,'_');
test_str=raw_data_name_components{1};
pathstr='D:\Matlab nelora/matlab/sf70/ins1/1';
[~,packet_index,~] = fileparts(pathstr);

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

% Set your onw paths
raw_data_dir='D:\Matlab nelora/matlab/sf70';
generated_data_dir = 'D:\Matlab nelora/matlab/';

% load settings
Fs = param_configs(3);         % sample rate
BW = param_configs(2);         % LoRa bandwidth
SF = param_configs(1);         % LoRa spreading factor
upsamping_factor = param_configs(4);         

nsamp = Fs * 2^SF / BW;
raw_data_list=scan_dir(raw_data_dir);
n_raw_data_list=length(raw_data_list);


feature_dir = [generated_data_dir,'sf7_125k/'];
if ~exist(feature_dir,'dir')
    mkdir(feature_dir);
end

SNR_minimal=-30;
SNR_list=[SNR_minimal:0,35];

chirp_down = Utils.gen_symbol(0,true);
disp(Fs)
