function [hour,minute,second] = s2hms(seconds)
% S2HMS This function is used to convert seconds to minutes and seconds
% e.g. [hour,minute,second] = s2hms(123456)
% Created by: Lucien
% E-mail: 2531989856@qq.com
% 2024-06-12

hour = fix(seconds/3600);
minute = fix((seconds-hour*3600)/60);
second = seconds-hour*3600-minute*60;

end

