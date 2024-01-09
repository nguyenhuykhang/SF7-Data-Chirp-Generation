function [iq_stream,iq_len] = io_read_iq(filename, samples)
    %RFILE read row signal from files
    %   [Data,N] = rfile(filename) returns the signal array and the number of samples
    %   [Data,N] = rfile(filename,samples) returns the first samples signal points
    fileID = fopen(filename, 'r');
    if fileID == -1, error('Cannot open file: %s', filename); end
    % gr_complex<float> is composed of two float32
    format = 'float'; %  format of the data in the file (float32)
    row = fread(fileID, Inf, format); %  data from the file into the 'row' array
    fclose(fileID);
    
    % Determine the number of IQ samples based on the input 'samples'
    if nargin < 2 || isempty(samples)
        iq_len = floor(size(row,1)/2);
    else
        iq_len = min(samples,floor(size(row,1)/2));
    end
    % Create the complex-valued IQ stream from the 'row' array
    iq_stream = zeros(1,iq_len); %: Initializes a zero vector for the complex-valued IQ stream.
    % complex-valued IQ stream by combining the real and imaginary parts from the 'row' array
    iq_stream(1:iq_len) = row(1:2:2*iq_len) + row(2:2:2*iq_len)*1i;
end