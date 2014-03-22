package code
{
	public class FigureRender extends Object
	{
		public static function renderFigure(dt:Array):DynamicMovie
		{
			var sp:DynamicMovie = new DynamicMovie();
			
			var xs,ys:Number = 0;
			
			var color:Number = Math.floor(0xFFFFFF * Math.random());
			
			for (var i:Number = 0; i < Config.boardSize; i++)
			{
				for (var j:Number = 0; j < Config.boardSize; j++)
				{
					if (dt[i*Config.boardSize + j] == 1)
					{
						xs = j*Config.cellSize;
						ys = i*Config.cellSize;
						
						sp.graphics.beginFill(color);
						sp.graphics.lineStyle(0, color);
						sp.graphics.drawRect(xs, ys, Config.cellSize, Config.cellSize);
						sp.graphics.endFill();
						
						var isDrawBorder:Array = new Array(4); // left, up, right, down
						isDrawBorder = [false, false, false, false];
						
						// check left
						if (j == 0)
						{
							isDrawBorder[0] = true;
						}
						else if (dt[i*Config.boardSize + j - 1] == 0)
						{
							isDrawBorder[0] = true;
						}
						
						// check right
						if (j == (Config.boardSize - 1))
						{
							isDrawBorder[2] = true;
						}
						else if (dt[i*Config.boardSize + j + 1] == 0)
						{
							isDrawBorder[2] = true;
						}
						
						// check up
						if (i == 0)
						{
							isDrawBorder[1] = true;
						}
						else if (dt[(i-1)*Config.boardSize + j] == 0)
						{
							isDrawBorder[1] = true;
						}
						
						// check down
						if (i == (Config.boardSize - 1))
						{
							isDrawBorder[3] = true;
						}
						else if (dt[(i+1)*Config.boardSize + j] == 0)
						{
							isDrawBorder[3] = true;
						}
						
						// draw left border
						var lineWeight:Number = 0.5;
						var lineColor:Number = 0;
						
						if (isDrawBorder[0])
						{
							sp.graphics.beginFill(lineColor);
							sp.graphics.lineStyle(lineWeight, lineColor);
							sp.graphics.moveTo(xs, ys);
							sp.graphics.lineTo(xs, ys + Config.cellSize);
							sp.graphics.endFill();
						}
						// draw up border
						if (isDrawBorder[1])
						{
							sp.graphics.beginFill(lineColor);
							sp.graphics.lineStyle(lineWeight, lineColor);
							sp.graphics.moveTo(xs, ys);
							sp.graphics.lineTo(xs + Config.cellSize, ys);
							sp.graphics.endFill();
						}
						// draw right border
						if (isDrawBorder[2])
						{
							sp.graphics.beginFill(lineColor);
							sp.graphics.lineStyle(lineWeight, lineColor);
							sp.graphics.moveTo(xs + Config.cellSize, ys);
							sp.graphics.lineTo(xs + Config.cellSize, ys + Config.cellSize);
							sp.graphics.endFill();
						}
						// draw bottom border
						if (isDrawBorder[3])
						{
							sp.graphics.beginFill(lineColor);
							sp.graphics.lineStyle(lineWeight, lineColor);
							sp.graphics.moveTo(xs, ys + Config.cellSize);
							sp.graphics.lineTo(xs + Config.cellSize, ys + Config.cellSize);
							sp.graphics.endFill();
						}
					}
				}
			}
			return sp;
		}
	}
}