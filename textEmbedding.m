function [x] = textEmbedding(key_char, filename_org, pathname_org, filename_encode, pathname_encode, filename_text_org, pathname_text_org)
x = 1;
if(strcmp(key_char, ' ') || strcmp(filename_org ,' ') || strcmp(pathname_org ,' ') || strcmp(filename_encode, ' ') || strcmp(pathname_encode ,' ') || strcmp(filename_text_org, ' ') || strcmp(pathname_text_org,' '))
    x=0;
    return; 
end
%open a wav file for hidding text
audio_org=fopen([pathname_org filename_org],'r');
header=fread(audio_org,40,'uint8=>char');
data_size=fread(audio_org,1,'uint32');
data=fread(audio_org,inf,'uint16') ;
fclose(audio_org);

lsb=1;
text_org=fopen([pathname_text_org filename_text_org],'r');
msg=fread(text_org,inf,'uint8');
fclose(text_org); 

msg_bin=de2bi(msg',8); %then convert message to binary
[m,n]=size(msg_bin);        %size of message binary
msg_bin_re=reshape(msg_bin,m*n,1);  %reshape the message binary in a column vector   
msg_length=length(msg_bin_re);       %length of message binary 

if msg_length > length(data)
     x=0;
     return;
else
    m_bin=de2bi(m,32)';
    n_bin=de2bi(n,32)';
    
    key_decimal = double(key_char);
    identity=0;
    for i = 1:length(key_decimal)
        identity = identity+key_decimal(i);
    end
    rng(identity, 'twister');
    randomizer_array = randperm(length(data)-64,msg_length);
    length_random = length(randomizer_array);

    %hide binary length of message in the last 64 bits of the data 
    data(length(data)-31:length(data))=bitset(data(length(data)-31:length(data)),lsb,n_bin(1:32));     
    data(length(data)-63:length(data)-32)=bitset(data(length(data)-63:length(data)-32),lsb,m_bin(1:32));
    data(randomizer_array(1:length_random))=bitset(data(randomizer_array(1:length_random)),lsb,msg_bin(1:msg_length)');
    
    %open a new wav file in write mode and copy the original header and text data
    audio_emb=fopen([pathname_encode filename_encode],'w');
    fwrite(audio_emb,header,'uint8');
    fwrite(audio_emb,data_size,'uint32');
    fwrite(audio_emb,data,'uint16');
    fclose(audio_emb);
end
end