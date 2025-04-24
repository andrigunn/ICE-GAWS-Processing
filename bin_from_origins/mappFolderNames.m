
%%
clc
for i = 1:length(FileList)
    
    if exist( [FileList(i).folder_L1], 'dir')

        cd([FileList(i).folder_L1]);
        cd ..
        
        d = dir();
        TF = contains([d.name],'L01');
        if TF == 1
            movefile L01 L1;
        else
        end
        
        TF = contains([d.name],'L00');
        if TF == 1
            movefile L00 L0;
        else
            
        end
        
        TF = contains([d.name],'LL2');
        if TF == 1
            disp('1')
            rmdir LL2;
        else
        end
    end
    
    
    
end