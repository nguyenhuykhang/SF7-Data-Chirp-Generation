% recursively scans a directory and returns a cell array containing the full paths of 
% all files within that directory and its subdirectories.
function [ files ] = scan_dir( root_dir )

files={};
if root_dir(end)~='/'
    root_dir=[root_dir,'/'];
end
fileList=dir(root_dir);  %Get directory structure
n=length(fileList);
cntpic=0;
for i=1:n
    if strcmp(fileList(i).name,'.')==1||strcmp(fileList(i).name,'..')==1
        continue;
    else
        %fileList(i).name
        if ~fileList(i).isdir % �������Ŀ¼������
            full_name=[root_dir,fileList(i).name];
            cntpic=cntpic+1;
            files(cntpic)={full_name};
        else
            files=[files,scan_dir([root_dir,fileList(i).name])];
        end
    end
end
end