function [x] = textRecover(key_decrypt,filename_encode, pathname_encode, filename_text_recover, pathname_text_recover)
x = 1;
if(strcmp(key_decrypt,' ') || strcmp(filename_encode,' ') || strcmp(pathname_encode, ' ') || strcmp(filename_text_recover, ' ') || strcmp(pathname_text_recover, ' '))
    x=0;
    return;
end
%open the file with hidden text
audio_emb=fopen([pathname_encode filename_encode],'r'); 
header=fread(audio_emb,40,'uint8=>char');
data_size=fread(audio_emb,1,'uint32');
data=fread(audio_emb,inf,'uint16');
fclose(audio_emb);

lsb=1;
%extract the length of text
m_bin=zeros(32,1);
n_bin=zeros(32,1);
n_bin(1:32)=bitget(data(length(data)-31:length(data)),lsb);
m_bin(1:32)=bitget(data(length(data)-63:length(data)-32),lsb);
msg_length=bi2de(m_bin')*bi2de(n_bin');
msg_bin=zeros(msg_length,1);

key_decimal = double(key_decrypt);
identity=0;
for i = 1:length(key_decimal)
    identity = identity+key_decimal(i);
end
rng(identity, 'twister');
randomizer_array = randperm(length(data)-64,msg_length);
length_random = length(randomizer_array);

%extract the lsb from wave data sample
msg_bin(1:msg_length)=bitget(data(randomizer_array(1:length_random)),lsb);
msg_bin_re=reshape(msg_bin,msg_length/8,8);
msg_dec=bi2de(msg_bin_re); %convert it to decimal
msg=char(msg_dec)';  %convert to char(ASCII)

text_rec=fopen([pathname_text_recover filename_text_recover],'w');
fprintf(text_rec,msg,'uint8'); 
fclose(text_rec);

end
