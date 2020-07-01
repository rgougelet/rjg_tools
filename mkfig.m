function mkfig(fig_h)
set(fig_h,'units','inches')
set(fig_h,'PaperUnits','inches')
set(fig_h,'MenuBar','none','ToolBar','none')
set(fig_h,'PaperOrientation','portrait')
set(fig_h,'PaperSize',[8.5 11]) %%for custom paper size
paper_size = get(fig_h,'PaperSize');
set(fig_h,'PaperPositionMode','manual')
set(fig_h,'PaperPosition',[0 0 paper_size(1) paper_size(2)]) % set position&size of the figure on the paper
% setting the position and size of the figure on the display shouldn't be necessary 
% since PaperPositionMode is set to 'manual'; but otherwise it doesn't work ...
set(fig_h,'Position',[0 0 paper_size(1) paper_size(2)])
% set(ax_h,'XLimMode','manual','YLimMode','manual')
% set(ax_h,'FontSize',14) (
