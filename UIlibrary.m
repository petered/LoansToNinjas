function F=UIlibrary
% Library of helpful user-interface functions.  Mostly uncommented to
% optimize user confusion.  An example of a full display function using
% some of these function is below.
% 
% Enjoy!
% 
% Author: Peter O'Connor
% Email: oconnorp ~at~ ethz ~dot~ ch
% 

%% Function Declarations
% Note that when no input argument is given, these must be referred to as
% F.functionnname(), otherwise just the funciton handle will be returned.
    
    F.addbuttons=@addbuttons;
    F.waitup=@waitup;
    F.uicutoff=@uicutoff;
    F.instructions=@instructions;
    F.activate=@activate;
    F.deactivate=@deactivate;
    F.subplotsetup=@subplotsetup;
    F.figtype=@figtype;
    F.readfield=@readfield;
    F.waitcmd=@waitcmd;
    F.getmouse=@getmouse;
    F.getmousebutton=@getmousebutton;
    F.addline=@addline;
    F.infobox=@infobox;
    F.namebutton=@namebutton;
    F.turnon=@turnon;
    F.turnoff=@turnoff;
    F.linkmaxes=@linkmaxes;
    F.linkmprop=@linkmprop;
    F.spookymap=@spookymap;
    F.drawprofile=@drawprofile;
    F.selectlims=@selectlims;
    F.header=@header;
    F.viewStruct=@viewStruct;
    F.stringify=@stringify;
    F.checkMenu=@checkMenu;
    F.buttons=@buttons;
    F.showtable=@showtable;
end

function [h valuefun]=buttons(varargin)
% Syntax
% h=U.buttons({button1.button2,...});
% h=U.buttons(hax,{button1.button2,...});
%
% Characters ~?:#! asre used to specify labels
%
% Specifying labels
% Examples
% 'label'                   - pushbutton named "label"
% '~label'                  - text with string "label"
% '~label:aaa'              - text with enterable field, default string 'aaa'
% '~label#123'              - text with enterable numeric field, default number 'aaa'
% '~label?1                 - label with checkbox, defaulting to true
% {'a','b'}                 - popup list with entries 'a','b'
% {'!checklist' 'a' 'b'}    - when option == checklist, drop-down checklist


%%  Setup Inputs
width=15;
height=1.2;
gap=2;

if ishandle(varargin{1}(1)) && strcmpi(get(varargin{1}(1),'type'),'axes')
   hax=varargin{1};
   varargin=varargin{2:end};    
   set(hax,'Units','characters');
   P=get(hax,'outerposition') + [0 -height 0 0];
else
   P=[0 0 0 0];
end

list=varargin{1};


% Location stuff
Hoffset=3+P(1);
Voffset=0+P(2);
locFun=@(j)[Hoffset+(width+gap)*(j-1) Voffset width height];

%% Run
hc=[]; 
h=nan(1,length(list));
valuefun=cell(size(h));
for i=1:length(list)
  if isempty(list{i}); % Which would cause a myserious error
      varargin{i}='  '; % Which should make it a button
  end

  if iscell(list{i})     % It's a pop-list

      if isnumeric(list{i})
          list{i}=arrayfun(@num2str,list{i},'uniformoutput',false);
      end
      
      % Crayyyyyzy function          
      if strcmpi(list{i}{1},'!checklist')
          list{i}=list{i}(2:end);
          [valuefun{i} h(i)]=checkMenu(list{i},[], 'Units','characters','Position',locFun(i));
      else
          h(i)=uicontrol('Style', 'popupmenu','String',list{i}, 'Units','characters','Position',locFun(i));
          valuefun{i}=@()list{i}{get(h(i),'value')};
      end
            
  elseif isnumeric(list{i}) % It's a numeric pop-list
      
      displist=arrayfun(@num2str,list{i},'uniformoutput',false);
      h(i)=uicontrol('Style', 'popupmenu','String',displist, 'Units','characters','Position',locFun(i));
      valuefun{i}=@()list{i}(get(h(i),'value'));
      
  elseif list{i}(1)=='~'    % There's text
      
      % Get first division
      r=regexp(list{i},{':' '?' '#'});
      filled=cellfun(@(r)~isempty(r),r);
      
      if any(filled) 
          div=r{find(filled,1)};
      else 
          div=length(list{i});
      end 
      
      
      hc=[hc uicontrol('Style','text', 'HorizontalAlignment','left','String',list{i}(2:div),'Units','characters','Position', locFun(i))]; 
      
            
      if ~any(filled), % Do fuck-all     
          h(i)=hc;
          valuefun{i}=@()get(h(i),'string');
      elseif filled(1) % There's a field
          h(i)=uicontrol('Style', 'edit', 'string',list{i}(div+1:end),'Units','characters','Position', locFun(i)+[div 0 -div 0]);
          valuefun{i}=@()get(h(i),'string');
      elseif filled(2) % There's a checkbox
          value=str2double(list{i}(div+1:end))>0;
          h(i)=uicontrol('Style', 'checkbox', 'value',value','Units','characters','Position', locFun(i)+[div 0 -div 0]);
          valuefun{i}=@()get(h(i),'value');
      elseif filled(3) % There's a numeric field
          h(i)=uicontrol('Style', 'edit', 'string',list{i}(div+1:end),'Units','characters','Position', locFun(i)+[div 0 -div 0]);
          valuefun{i}=@()str2num(get(h(i),'string'));
      end
      
  else %    It's a button
      h(i)=uicontrol('Style', 'PushButton', 'String',list{i},'Units','characters','Position', locFun(i)); 
      valuefun{i}=get(h(i),'value');
  end

end

h=[h hc(ishandle(hc)&hc~=0)];  
% Add handles handles with no responsiveness to the end, so they can
% still be hidden and deleted and stuff.
if ~ismac
   bgcol=get(gcf,'Color');
   set(h,'BackgroundColor',round(bgcol),'ForegroundColor',1-round(bgcol));
end

set(gcf,'Toolbar','figure');                      




end

function h=addbuttons(varargin)
   % Add Buttons to a figure
   % Special Characters:
   % :  - (at end)              Edit Field
   % %? - (at end)              Checkbox
   % ~  - (at beginning)        Plain Text 
   % |  - (between strings)     Separates items in a drop-box
   
%    if iscell(varargin{1}),varargin=varargin{1}; end

   

   width=22;
   height=1.2;
   gap=2;

   
   
   [i j k]=deal(1);
   P=[0 0 0 0];
   while true
       
       if ishandle(varargin{i}(1)) && strcmpi(get(varargin{i}(1),'type'),'axes')
           set(varargin{i},'Units','characters');
           P=get(varargin{i},'outerposition') + [0 -height 0 0];
           set(varargin{i},'Units','normalized');
       elseif isnumeric(varargin{i})
            j=varargin{1};
       else
           break;
       end
       
       i=i+1;    
       
   end
   
   
   Hoffset=3+P(1);
   Voffset=0+P(2);
   
   hc=[];   
   
   
   while i<=length(varargin)
      if isempty(varargin{i}); % Which would cause a myserious error
          varargin{i}='  '; % Which should make it a button
      end
       
      if iscell(varargin{i})
          
          % Crayyyyyzy function
          varargin{i}=reshape(strcat(char(cellfun(@(x)num2str(x),varargin{i},'uniformoutput',false)),'|')',[],1)';
                    
          loc=0;
          
          if varargin{i}(end)=='|',varargin{i}(end)=''; end
          thing=varargin{i}(loc+1:end);
          
          h(k)=uicontrol('Style', 'popupmenu', 'Units','characters','String',thing,'Position', ...
              [Hoffset+(width+gap)*(j-1)+loc+1 Voffset width-loc-1 height],...
              'Callback','uiresume(gcbf)'); 
          
          
          
      
      elseif ~isempty(strfind(varargin{i},':'))    % It's a field

          hc(k)=uicontrol('Style', 'text', 'HorizontalAlignment','left','String',varargin{i}, 'Units','characters',...
          'Position', [Hoffset+(width+gap)*(j-1) Voffset width height]); 

          h(k)=uicontrol('Style', 'edit', 'Units','characters','Position', ...
              [Hoffset+(width+gap)*(j-1)+length(varargin{i})+1 Voffset 5 height],...
              'Callback','uiresume(gcbf)'); 
          
      elseif strcmp(varargin{i}(end-1:end),'%?')  % It's a checkbox
          hc(k)=uicontrol('Style', 'text', 'HorizontalAlignment','left','String',varargin{i}(1:end-2), 'Units','characters',...
          'Position', [Hoffset+(width+gap)*(j-1) Voffset width height]); 

          h(k)=uicontrol('Style', 'checkbox', 'Units','characters','Position', ...
              [Hoffset+(width+gap)*(j-1)+length(varargin{i})+1 Voffset 5 height],...
              'Callback','uiresume(gcbf)'); 
          
      elseif varargin{i}(1)=='~'    % It's just text
          h(k)=uicontrol('Style', 'text', 'HorizontalAlignment','left','String',varargin{i}(2:end), 'Units','characters',...
          'Position', [Hoffset+(width+gap)*(j-1) Voffset width height]);
          
      elseif any(strfind(varargin{i},'|')) || isnumeric(varargin{i})   % It's a drop-box
                    
          % Format for list if its a vector
          if isnumeric(varargin{i})
              varargin{i}=reshape(strcat(num2str(varargin{i}(:)),'|')',[],1)';
          end
          
          if strfind(varargin{i},'~') 
              loc=find(varargin{i}=='~',1);

              hc(k)=uicontrol('Style', 'text', 'HorizontalAlignment','left','String',varargin{i}(1:loc-1), 'Units','characters',...
                'Position', [Hoffset+(width+gap)*(j-1) Voffset width height]); 
          else
              loc=0;
          end
          if varargin{i}(end)=='|',varargin{i}(end)=''; end
          thing=varargin{i}(loc+1:end);
          
          h(k)=uicontrol('Style', 'popupmenu', 'Units','characters','String',thing,'Position', ...
              [Hoffset+(width+gap)*(j-1)+loc+1 Voffset width-loc-1 height],...
              'Callback','uiresume(gcbf)'); 
          
          
          

      else                          % If it's a button
          h(k)=uicontrol('Style', 'PushButton', 'String',varargin{i},'Units','characters',...
               'Position', [Hoffset+(width+gap)*(j-1) Voffset width height],...
              'Callback','uiresume(gcbf)'); 
      end
      
      
      if ~isempty(P)
          set(h(k),'Units','normalized');
%           set(h(k),'position',get(hK
      end

      i=i+1;
      j=j+1;
      k=k+1;
   end

   h=[h hc(ishandle(hc)&hc~=0)];  
   % Add handles handles with no responsiveness to the end, so they can
   % still be hidden and deleted and stuff.
   if ~ismac
       bgcol=get(gcf,'Color');
       set(h,'BackgroundColor',bgcol,'ForegroundColor',round(mod(bgcol+0.5,1)));
   end
   
   set(gcf,'Toolbar','figure');                      
           
end

function waitup(hF)
%%
    if ~exist('hF','var'),hF=gcf; end;
    uiwait(hF);
    if isempty(gco)||~ishandle(hF)
%        evalin('caller','evalin(''caller'', ''return;'')'); 
        evalin('caller','return;'); % Doesn''t freaking work
%         dbquit;
    end
end

function [L hL]=uicutoff(L,hL)
% This function is designed for when you need to set a pair of cutoff
% points with the mouse, in the current axis;
    
    P=get(gca,'CurrentPoint');

    switch get(gcf,'SelectionType')
        case 'normal',  side=1;
        case 'alt',     side=2;
    end

    L(side)=P(1);
    if ishandle(hL(side)), delete(hL(side)); end
    hL(side)=addline(L(side));
    set(hL(side),'HitTest','off');
    
    drawnow;

end

function inst=instructions(type)
    switch type
        case 'cutoffs'
            inst='Specify a left and right cutoff by using the left/right mouse buttons.  ';
    end

end

function activate(handle)

    set(handle,'ButtonDownFcn','uiresume(gcbf)');

    hkids=get(handle,'Children');
    
    if numel(handle)>1
        hkids=cell2mat(hkids);
    end
    
    set(hkids,'HitTest','off');    

end

function deactivate(handle)

    set(handle,'ButtonDownFcn','');

end

function [nR nC]=subplotsetup(N,rowfirst)
    
    if ~exist('rowfirst','var'), rowfirst=false; end;
    
    if ~rowfirst
        nC=floor(sqrt(N));
        nR=ceil(N/nC);
    else
        nR=floor(sqrt(N));
        nC=ceil(N/nR);
    end

    

end

function fld=readfield(h)

    if ~exist('h','var'),h=gco; end

    switch get(h,'style');
        case 'popupmenu'
            fld=get(h,'value');
        otherwise
            fld=str2num(get(h,'string')); %#ok<*ST2NM>
    end

end

function cmd=waitcmd(hF,hax,mouse) %#ok<INUSL>
    % Use eval(F.waitcmd(hF)), where hF is the figure handle, to pause
    % execution while waiting for user input.  The calling function will
    % return without error if the figure is closed.

    if exist('hax','var'),activate(hax);end
    
    if nargin>0, hF=inputname(1);
    else hF='gcf';
    end
    
    if ~exist('mouse','var')||isempty(mouse), pointer='arrow';
    else
        switch mouse
            case 'a', pointer='arrow';
            case 'x', pointer='crosshair';
            case 'X', pointer='fullcrosshair';
            case 'I', pointer='ibeam';
            case 'w', pointer='watch';
        end
    end
    

    cmd=['set(' hF ',''Pointer'',''' pointer '''); uiwait(' hF '); if isempty(gco)||~ishandle(' hF ') return; end; set(' hF ' ,''Pointer'',''arrow'');'];    

end

function [x y b]=getmouse(roundit)

    if ~exist('roundit','var'), roundit=false; end
    
    P=get(gca,'CurrentPoint');
    x=P(1,1);
    y=P(1,2);
    
    if roundit
        x=round(x);
        y=round(y);
    end
    
    if nargout==3
        b=getmousebutton;        
    end
            

end

function b=getmousebutton
    but=get(gcf,'SelectionType');
    switch but
        case 'normal',  b=1;
        case 'extend',  b=2;
        case 'alt',     b=3;
        case 'open',    b=4;
        otherwise,      b=0; % Shouldn't ever get here.
    end

end

function [h hF]=figtype(type,N)
    % Takes a plot type description, creates a figure and returns handles to the axes

    screen=get(0,'ScreenSize');
    screen=screen(3:4);
    
    hF=figure;
    set(gcf,'DefaultAxesColorOrder',circshift(lines,[0 1]));
    switch lower(type)
        case 'lr'
            h=[subplot(1,2,1) subplot(1,2,2)];
            set(gcf,'Position',[200 200 1200 750]);
        case 'tb'
            h=[subplot(2,1,1) subplot(2,1,2)];
            set(gcf,'Position',[200 200 1200 750]);
        case 'rows'
            h=nan(1,N);
            for i=1:N
                h(i)=subplot(N,1,i);
            end
            set(gcf,'Position',[200 200 1200 750]);
        case 'cols'
            h=nan(1,N);
            for i=1:N
                h(i)=subplot(1,N,i);
            end
%             set(gcf,'Position',[100 200 screen(1)-100 min(screen(1)/N,screen(2)-300)]);
            
        case 'dim'
            h=nan(N)';
            for i=1:prod(N)
                h(i)=subplot(N(1),N(2),i);
            end
            h=h';
            set(gcf,'Position',[200 200 1200 750]);
        case 'ltrbr'
            nR=2;
            nC=5;
            ixC=sub2ind([nC,nR],[1 2 1 2],[1 1 2 2]);
            ixP=sub2ind([nC,nR],[3 4 5],[1 1 1]);
            ixF=sub2ind([nC,nR],[3 4 5],[2 2 2]);
            h=[subplot(nR,nC,ixC) subplot(nR,nC,ixP) subplot(nR,nC,ixF)];
            set(gcf,'Position',[200 200 1200 750]);
        case 'tlblr'
            nR=2;
            nC=5;
            ixC=sub2ind([nC,nR],[1 2 3],[1 1 1]);
            ixS=sub2ind([nC,nR],[1 2 3],[2 2 2]);
            ixR=sub2ind([nC,nR],[4 5 4 5],[1 1 2 2]);
            h=[subplot(nR,nC,ixC) subplot(nR,nC,ixS) subplot(nR,nC,ixR)];
            set(gcf,'Position',[200 200 1200 750]);
        case 'standard'
            [nR nC]=subplotsetup(N,true);
            h=nan(1,N);
            for i=1:N
                h(i)=subplot(nR,nC,i);
            end
            set(gcf,'Position',[200 200 1200 750]);
            
        otherwise
            h=[];
    end

end
    
function h=addline(strips, orient, varargin)

% Simple Way to add vertical or horizontal lines to a plot. 
% Examples: 
% h=addline([1 1.4 2],'h','color','r');  Would add 3 horizontal red lines
%                                        to your plot at x=[1 1.4 2].
% addline([1 1.4 2]);                    Would add 3 vertical grey lines at
%                                        these points.
% addline([3 4.2], 'vh')                 Would add crosshairs at x=3,y=4.2
% 
% 'strips' specifies the coordinates of the strips, 
% 'color', specifies the colour of each line.  If there are 3 columns, it 
% will be interpretied as RGB.  color can also be a predefined color.  The
% rows of the 'colour' vector represent the color for each line.  The 
% colour for each line is determined by rotating around the colour vectors.
% 'LineStyle' will be interpreted as it is in the Matlab 'line' function.


%% Get Arguments

% To keep compatibility with older versions
if exist('orient','var')&&~all(orient=='v'|orient=='h'), 
    varargin=[orient varargin];
    orient='v';
end

for i=1:2:(length(varargin)-1)
   if strcmpi('Color', varargin{i})
       colour=varargin{i+1};
   elseif strcmpi('LineStyle', varargin{i})
       pattern=varargin{i+1}; 
   elseif strcmpi('LineWidth', varargin{i})
       width=varargin{i+1}; 
   % compatibility...
   elseif strcmpi('orientation', varargin{i})
       
       switch varargin{i+1}
           case 0, orient='v';
           case 1, orient='h';
       end
%    /compatibility
   else
       disp('This function takes "satfire", "threshold", and "show" as arguments.  None of this ', varargin{i}, ' nonsense');
   end
end
   
%% Set Defaults

% Default Color
if ~exist('colour', 'var')
    colour=[.5 .5 .5];
elseif strcmp(colour, 'auto')
    colour=(lines(size(strips,2)));    
end

% Default Orientation: vertical
if ~exist('orient', 'var')
    orient='v'; %meaning vertical
end

% Get full orientation vector
if numel(orient)==1
    orient=repmat(orient,[1 length(strips)]);
elseif numel(orient)~=numel(strips)
    disp('Warning: Wrong number of line orientations provided for line vector.  Lines will not be plotted');
    h=-1;
    return;
end

% Line patten default
if ~exist('pattern', 'var')
    pattern='-';
end

% Line width default
if ~exist('width', 'var')
    width=1;
end

%% Actual program

% Get previous axis settings
v=axis;
a=ishold;
xlim=get(gca,'XLim');
ylim=get(gca,'YLim');

hold on
axis manual

% h=NaN([1 length(strips)]);
% for i=1:length(strips)
%     col=colour(mod(i-1,size(colour,1))+1,:);
%     if orient(i)=='h'
%     h(i)=line([v(1) v(2)],[strips(i) strips(i)],  'color', col, 'LineStyle', pattern,'LineWidth',width);  
%     elseif orient(i)=='v'
%     h(i)=line([strips(i) strips(i)], [v(3) v(4)], 'color', col, 'LineStyle', pattern,'LineWidth',width);
%     end
% end

[xtags ytags]=deal(nan(2,length(strips)));


strips=strips(:)';
if any(orient=='v')
    xtags(:,orient=='v')=repmat(strips(orient=='v'),[2,1]);
    ytags(:,orient=='v')=repmat(v([3 4])',[1 nnz(orient=='v')]);
end
if any(orient=='h')
    xtags(:,orient=='h')=repmat(v([1 2])',[1 nnz(orient=='h')]);    
    ytags(:,orient=='h')=repmat(strips(orient=='h'),[2,1]);
end

h=plot(xtags,ytags, 'color', colour, 'LineStyle', pattern,'LineWidth',width);



if ~a, hold off; end

set(gca,'Xlim',xlim);
set(gca,'Ylim',ylim);


end

function infobox(text,titl)
    if ~exist('tit1','var'),titl=''; end
    hH=msgbox(text,titl);
    uiwait(hH);

end

function namebutton(str,handle)

    if ~exist('handle','var'), handle=gco; end;
    
    set(handle,'string',str);

end

function turnon(handle)

    set(handle,'Visible','on'); set(handle,'HitTest','on');

end

function turnoff(handle)

    set(handle,'Visible','off'); set(handle,'HitTest','off');

end

function hL=linkmaxes(h,type)
% Improvement on the built in linkaxes function - it scales to the maximum
    if ~exist('type','var'), type='xy'; end
    
    if all(ismember(type,'xyzc'))
        hL=linkmprop(h,strcat(num2cell(type),'lim'));
    else
        error('"%c" not recognizes as an axes type to link.',type(~ismember(type,'xyzc')));
    end
%     
%     
%     for i=1:length(type)
%         if ismember(type(i),'xyzc')
%             linkmprop(h,[type(i),'lim']);
%         else
%             error('"%c" not recognizes as an axes type to link.',type(i));
%         end
%     end    

end

function hL=linkmprop(h,prop)

    if ~iscell(prop), prop={prop}; end

    for i=1:length(prop)
        arr=get(h,prop{i});
        if numel(h)>1, arr=cell2mat(arr); end
        arr=[min(arr(:,1))  max(arr(:,2))];
        set(h,prop{i},arr);
    end
    hL=linkprop(h,prop);
    
end

function map=spookymap(power)

    if ~exist('power','var'), power=1; end
    
    % Get max color limits
    hA=get(get(gcf,'children'),'children');
    if iscell(hA), hA=cell2mat(hA);end
    
    
    hA=get(hA( ...
        strcmp(get(hA,'type'),'image') & arrayfun(@(x)isempty(strfind(get(x,'tag'),'COLORBAR')),hA)),...
        'parent');
    if iscell(hA), hA=cell2mat(hA);end
%     hA=hA(arrayfun(@(x)strcmp(get(x,'type'),'axes'),hA));
    lims=cell2mat(arrayfun(@(x)get(x,'clim'),hA,'uniformoutput',false));
    lims=[min(lims(:,1)) max(lims(:,2))];
    
%     lims=get(gca,'clim');
    
    n=64;
    
    absmax=max(abs(lims));
    
    cm=linspace(lims(1)/absmax,lims(2)/absmax,n)';
        
    redness=(cm(cm>=0));
    blueness=-(cm(cm<0));
    
    
    map=[zeros(size(blueness,1),2) blueness; redness zeros(size(redness,1),2)];
    
%     greeness=[1-blueness; 1-redness]/2;
%     map(:,2)=greeness;
    greyfactor=0.5;
    if isempty(redness)
        greyness=greyfactor*linspace(1,0,length(blueness));
    elseif isempty(blueness)
        greyness=greyfactor*linspace(0,1,length(redness));
    else
        greyness=greyfactor*[linspace(0,1,length(blueness)), linspace(1,0,length(redness))];
    end
        
    map=map+repmat(greyness(:),[1 3]);
    
    if power~=1,
        map=map.^power;
    end
        
    if nargout==0, colormap(map); end


end

function h=drawprofile(dir)

    [x y b]=getmouse;
    if ~exist('dir','var')
        switch b
            case 3, dir='h';
            otherwise, dir='v';
        end
    end
    switch dir
        case 'v', val=x; lm='xy';
        case 'h', val=y; lm='yx';
    end
    
    switch get(gco,'type')
        case 'axes'
            aa=get(gco,'children');
            obj=aa(find(strcmpi(get(aa,'type'),'image'),1));
            
        case 'image'
            obj=gco;
        
    end
    
    if isempty(obj)
        disp('Object is not an image, returning.');
        h=[nan nan];
        return;
    end
    
    
    points=get(obj,[lm(2) 'data']);
    
    
    data=get(obj,'cdata');
    if size(data,3)==1, % Not wasteful cause it should just be a handle
        data=get(obj,'cdata');
    else % Maybe someone pulled a freezecolors
        shtuff=getappdata(obj,'JRI__freezeColorsData');
        if isempty(shtuff), 
            disp 'Original data does not exist.  Not drawing anything';
            h=[nan nan];
            return;
        end
        data=shtuff{1};
    end
        
    
    
    if numel(points)==2, points=linspace(points(1),points(2),size(data,find(dir=='vh',1))); end
    
    opax=get(obj,[lm(1) 'data']);
    ix=ceil( size(data,find(dir=='hv',1)) * (val-opax(1)) / (opax(end)-opax(1))  );
    
    
    switch dir
        case 'v'
            data=data(:,ix);
        case 'h'
            data=data(ix,:);
    end
    
    scalefac=diff(get(gca,'clim'));
    if dir=='h',scalefac=-scalefac; end % because + -> right, up.
    data=data/scalefac*diff(get(gca,[lm(1) 'lim']))/6+val;
    
    
    h(1)=addline(val,dir,'LineStyle',':');
    switch dir 
        case 'v'
            h(2)=line(data,points,'color','w');
        case 'h'
            h(2)=line(points,data,'color','w');
    end
    
    
    get(gcf,'currentobject');

end

function [lims hL]=selectlims(type,ax,firstset,deletelines)

    if ~exist('type','var')||isempty(type), type='index'; end
    if ~exist('ax','var')||isempty(ax), ax=gca; end
    if ~exist('firstset','var')||isempty(firstset), firstset=false; end
    if ~exist('deletelines','var')||isempty(deletelines), deletelines=true; end
    
    oldtit=get(get(ax,'title'),'string');

    title 'Select Left/right Limits with L/R mouse buttons'

    [lims hL]=deal([nan nan]);
    activate(ax);

    
    while 1

        if ~firstset
            uiwait(gcf);
        else 
            firstset=false;
        end


        if (gco==ax)
            
            [x y b]=getmouse();
            
            switch b
                case 1, lims(1)=x;
                case 3, lims(2)=x;
            end
        end

        delete(hL(ishandle(hL)));
        hL=addline(lims);

        if ~any(isnan(lims)),break; end


    end
    
    if strcmpi(type,'index')
        
        han=get(gca,'children');
        han=han(end);

        xlims=get(han,'xdata');

        switch get(han,'type')
            case 'line'
                sz=length(xlims);
            case 'image'
                sz=size(get(han,'CData'),2);
            otherwise
                disp 'Unrecognised plot type.  Returning nothing'
                lims=[];
                return;
        end

        lims=ceil(sz*(lims-xlims(1))/(xlims(end)-xlims(1)));

    end
    
    if deletelines
        delete(hL(ishandle(hL)));
    end
    
        
    title(oldtit);






end

function header(texxxt,VA,xy)
   %%
   warning off MATLAB:Tex

   if ~exist('VA','var')||isempty(VA), VA='bottom'; 
   else 
       switch lower(VA)
           case 'top', VA='bottom';
           case 'bot', VA='top'; % No that's not a mistake
       end
   end
   if ~exist('xy','var')||isempty(xy),xy=[1 1]; end    
   

   text(xy(1),xy(2),texxxt,'Units','normalized',...
       'VerticalAlignment',VA,...
       'HorizontalAlignment','right');

end

function h=viewStruct(S,fieldlist)

    if ~exist('fieldlist','var'), fieldlist=fields(S); end

    
    
    
    
    C=cell(length(S),length(fieldlist));
    if ~isempty(S)
        for i=1:length(fieldlist)

            C(:,i)=cellfun(@stringify,{S.(fieldlist{i})},'UniformOutput',false);    


        end
    end
    h=uitable('Data',C,'ColumnName',fieldlist,'Units','normalized','position',[0 0 1 1]);
    
    set(gcf,'name',class(S));
    
end

function hT=showtable(varargin)

if ~ishandle(varargin{1})
    hF=figure;
else
    hF=varargin{1};
end

hT=uitable(varargin{:});

pf=get(hF,'position');
pt=get(hT,'position');

pf(3:4)=2*pt(1:2)+pt(3:4);

set(hF,'position',pf);

end

function str=stringify(num)

    s=size(num);
    if ischar(num), str=num; 
    elseif isnumeric(num) && nnz(s>1)<2 && max(s)<6
        str=num2str(num);
    else
        s=size(num);
        str=['<' regexprep(num2str(s),'  ','x') class(num) '> '];
    end

end



    function [s hB]=checkMenu(options,initial,varargin)
    % Creates a popup checkbox list.  You can access the state (true or false)
    % of each item through output s.  varargin can be filled with whatever
    % other popupmenu properties you want to add
    %
    % Example use:
    % s=checkMenu({'foo','bar'},[true false]);
    % s.foo()
    % s.bar()
    %
    % woohoo


    hB=uicontrol('style','popupmenu','callback',@(s,e)selectItem,varargin{:});

    if ~exist('initial','var')||isempty(initial)
        tog=false(size(options));
    elseif length(initial)~=length(options) 
        error('Your list of initial values has a different length than your list of options!');
    else
        tog=initial;
    end

    for i=1:length(options)
       s.(options{i})=@()returnItem(i);
    end

        % Callbacks
        function val=returnItem(i)
            val=tog(i);
        end

        function L=refreshlist
            L=cellfun(@(tg,op)sprintf('%c %s',char(10005-tg),op),num2cell(tog),options,'uniformoutput',false);
            set(hB,'string',L);
        end

        function selectItem
            item=get(hB,'value');
            tog(item)=~tog(item);
            refreshlist;
        end

    refreshlist;

    end