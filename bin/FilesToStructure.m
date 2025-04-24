FileList = readFileList('L2','daily');
%
FilterFileList = filterFileList(FileList,'',1980,2024);
%
data = readFileListToStructure(FilterFileList)
%%
JoinedData = JoinDataFromStructureToTimetable(data,'')

%% Add degree days
JoinedData.B10.DD(JoinedData.B10.t>0) = 1;
%%
[Rt,Rc,TB] = makeOverlayDataStack(JoinedData.B10.Time,JoinedData.B10.DD)
%%
figure, hold on
plot(Rc.Time,Rc.HY_2022)
plot(Rc.Time,Rc.HY_2021)
plot(Rc.Time,Rc.AY_median,'LineWidth',2)
%%
figure, hold on
plot(JoinedData.B10.Time,JoinedData.B10.t)
plot(JoinedData.B13.Time,JoinedData.B13.t)
plot(JoinedData.B16.Time,JoinedData.B16.t)

figure, hold on
plot(JoinedData.T01.Time,JoinedData.T01.t)
plot(JoinedData.T03.Time,JoinedData.T03.t)
plot(JoinedData.T06.Time,JoinedData.T06.t)
