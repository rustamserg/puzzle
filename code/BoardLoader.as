package code
{
	import flash.display.MovieClip;
	import flash.net.URLLoader;
	import flash.net.URLVariables;
	import flash.net.URLRequestMethod;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.events.Event;
	
	import flash.geom.Point;
	
	public class BoardLoader extends MovieClip
	{
		private var m_arrFig:Array = new Array();
		private var m_board:Board; 
	
		
		public function loadPuzzle():void
		{
			var matrix:Array = cleanBoard;
			
			// plant seeds
			for (var sid = 1; sid <= Config.boardCells; sid++)
			{
				while (true)
				{
					var xs:Number = randRange(0, Config.boardSize - 1);
					var ys:Number = randRange(0, Config.boardSize - 1);
					if (matrix[xs + ys*Config.boardSize] == 0)
					{
						matrix[xs + ys*Config.boardSize] = sid;
						break;
					}
				}
			}
			
			// grow seeds
			while (true)
			{
				// iterate over plant and try to join free slots
				for (var xp = 0; xp < Config.boardSize; xp++)
				{
					for (var yp = 0; yp < Config.boardSize; yp++)
					{
						if (matrix[xp + yp*Config.boardSize] > 0)
							continue;
						
						// pickup seeds around
						var seeds:Array = new Array(4);
						for (var dir_idx = 0; dir_idx < 4; dir_idx++)
						{
							seeds[dir_idx] = 0;
							var seed_x = xp;
							var seed_y = yp;

							if (dir_idx == 0 && seed_y > 0) seed_y--; // up
							if (dir_idx == 1 && seed_y < (Config.boardSize - 1)) seed_y++; // down
							if (dir_idx == 2 && seed_x > 0) seed_x--; // left
							if (dir_idx == 3 && seed_x < (Config.boardSize - 1)) seed_x++; // right
						
							var joint_seed_id = matrix[seed_x + seed_y*Config.boardSize];
							if (joint_seed_id == 0)
								continue;
								
							var seed_count:Number = 0;
							for each (var sc in matrix)
								if (sc == joint_seed_id) seed_count++;
							seeds[dir_idx] = seed_count;
						}
						
						// randomly select lowest seed count
						var max_weight = seeds[0] + seeds[1] + seeds[2] + seeds[3];
						var pick_weight:Number = randRange(0, max_weight);
						for (var dir = 0; dir < 4; dir++)
						{
							if (seeds[dir] == 0)
								continue;
							
							if (pick_weight <= (max_weight - seeds[dir]))
							{
								var seed_x = xp;
								var seed_y = yp;

								if (dir == 0) seed_y--; // up
								if (dir == 1) seed_y++; // down
								if (dir == 2) seed_x--; // left
								if (dir == 3) seed_x++; // right
								
								matrix[xp + yp*Config.boardSize] = matrix[seed_x + seed_y*Config.boardSize];
								break;
							}
						}
					}
				}
	
				// check if all matrix is filled fully
				var filled:Boolean = true;
				for each (var sd:Number in matrix)
				{
					if (sd == 0)
					{
						filled = false;
						break;
					}
				}
				if (filled) break;
			}
			createPuzzle(matrix);
		}
		
		private function get cleanBoard():Array
		{
			var matrix:Array = new Array(Config.boardSize*Config.boardSize);
			for (var x = 0; x < Config.boardSize; x++)
				for (var y = 0; y < Config.boardSize; y++)
					matrix[x + y*Config.boardSize] = 0;
			return matrix;
		}
		
		private function randRange(min:Number, max:Number):Number
		{
    		var randomNum:Number = Math.floor(Math.random() * (max - min + 1)) + min;
    		return randomNum;
		}
	
		private function createPuzzle(matrix:Array):void
		{
			// clear current stage
			if (m_board && contains(m_board)) removeChild(m_board);
			
			for (var i:Number = 0; i < m_arrFig.length; i++)
				if (contains(m_arrFig[i])) m_board.removeChild(m_arrFig[i]);
			
			m_arrFig.splice(0);
			
			// create new board for figures
			m_board = new Board();
			addChild(m_board);
			
			// create new figures and add them
			var arrID:Array = new Array();
			
			for (var iX:Number = 0; iX < Config.boardSize; iX++)
			{
				for (var iY:Number = 0; iY < Config.boardSize; iY++)
				{
					var iD:Number = matrix[iY*Config.boardSize + iX];
					if ((iD > 0) && (arrID.indexOf(iD) == -1))
					{
						// found new figure
						arrID.push(iD);
						m_arrFig.push(createFigureByID(matrix, iD));
					}
				}
			}
			
			// initiate figure pos
			var figSX:Number = Config.boardPosX + (Config.boardSize + 1)*Config.cellSize;
			var figSY:Number = Config.boardPosY + Config.cellSize;
			var figStepY:Number = ((600 - Config.cellSize) - figSY)/(m_arrFig.length/2); // 2 columns
			var figStepX:Number = ((800 - Config.cellSize) - figSX)/2;
			var figOffsetZ:Number = 0;
			
			// adjust figure starting point on center of landing quad
			figSX = figSX + figStepX/2;
			figSY = figSY + figStepY/2;
			
			var figX:Number = figSX;
			var figY:Number = figSY;
			
			for (i = 0; i < m_arrFig.length; i++)
			{
				m_board.addChild(m_arrFig[i]);
				
				// randomly rotate each figure
				var rotIdx:Number = Math.floor(Math.random()*12);
				
				for (var j:Number = 0; j < rotIdx; j++)
					m_arrFig[i].rotateCWFigure();
					
				// set figure on board
				m_arrFig[i].setFigurePos(figX, figY);
				
				figY += (figStepY + figOffsetZ);
				if (figY >= (600 - Config.cellSize))
				{
					figX += (figStepX + figOffsetZ);
					figY = figSY;
					
					if (figX >= (800 - Config.cellSize))
					{
						figX = figSX;
						figOffsetZ += Config.cellSize/3;
					}
				}
			}
		}
		
		private function createFigureByID(matrix:Array, iD:Number):Figure
		{
			var fig:Figure = new Figure(m_board);
			
			// identify upper-left point of figure
			var ulPX, ulPY, ulP:Point;
			var iX,iY:Number;
			
			ulPX = new Point(-1, -1);
			ulPY = new Point(-1, -1);
			ulP = new Point(-1, -1);
			
			for (iX = 0; iX < Config.boardSize; iX++)
			{
				for (iY = 0; iY < Config.boardSize; iY++)
				{
					if (iD == matrix[iY*Config.boardSize + iX])
					{
						ulPY.y = iY;
						ulPY.x = iX;
						break;
					}
				}
				if (ulPY.y >= 0) break;
			}
			for (iY = 0; iY < Config.boardSize; iY++)
			{
				for (iX = 0; iX < Config.boardSize; iX++)
				{
					if (iD == matrix[iY*Config.boardSize + iX])
					{
						ulPX.x = iX;
						ulPX.y = iY;
						break;
					}
				}
				if (ulPX.x >= 0) break;
			}
			
			// define point of interception
			ulP.x = Math.min(ulPX.x, ulPY.x);
			ulP.y = Math.min(ulPX.y, ulPY.y);
			
			// fill figure matrix
			for (iX = 0; iX < Config.boardSize*Config.boardSize*4; iX++)
				fig.m_data[iX] = 0;
				
			for (iY = ulP.y; iY < Config.boardSize; iY++)
			{
				for (iX = ulP.x; iX < Config.boardSize; iX++)
				{
					if (iD == matrix[iY*Config.boardSize + iX])
					{
						fig.m_data[(iY - ulP.y)*Config.boardSize + (iX - ulP.x)] = 1;
					}
				}
			}
			
			// fill transformation matrix
			for (var rotIdx:Number = 1; rotIdx < 4; rotIdx++)
			{
				var srcData:Array = fig.m_data.slice((rotIdx - 1)*Config.boardSize*Config.boardSize);
				
				// define bottom-right point
				ulPX.x = ulPX.y = ulPY.x = ulPY.y = -1;
				
				for (iX = (Config.boardSize - 1); iX >= 0; iX--)
				{
					for (iY = (Config.boardSize - 1); iY >= 0; iY--)
					{
						if (1 == srcData[iY*Config.boardSize + iX])
						{
							ulPY.y = iY;
							ulPY.x = iX;
							break;
						}
					}
					if (ulPY.y >= 0) break;
				}
				for (iY = (Config.boardSize - 1); iY >= 0; iY--)
				{
					for (iX = (Config.boardSize - 1); iX >= 0; iX--)
					{
						if (1 == srcData[iY*Config.boardSize + iX])
						{
							ulPX.x = iX;
							ulPX.y = iY;
							break;
						}
					}
					if (ulPX.x >= 0) break;
				}
			
				// define point of interception
				ulP.x = Math.max(ulPX.x, ulPY.x);
				ulP.y = Math.max(ulPX.y, ulPY.y);

				// tranformation
				for (iX = 0; iX <= ulP.x; iX++)
				{
					for (iY = 0; iY <= ulP.y; iY++)
					{
						fig.m_data[iX*Config.boardSize + (ulP.y - iY) + 
									rotIdx*Config.boardSize*Config.boardSize] = srcData[iY*Config.boardSize + iX];
					}
				}
			}
			fig.addFigure(FigureRender.renderFigure(fig.m_data));
			return fig;
		}
		
		public function resetPuzzle():void
		{
			m_board.resetBoard();
			
			for (var i:Number = 0; i < m_arrFig.length; i++)
			{
				m_arrFig[i].resetPos();
				
				var rotIdx:Number = Math.floor(Math.random()*12);
				
				for (var j:Number = 0; j < rotIdx; j++)
					m_arrFig[i].rotateCWFigure();
			}
		}
		
		public function stopPuzzle():void
		{
			for (var i:Number = 0; i < m_arrFig.length; i++)
			{
				m_arrFig[i].stopFigure();
			}
		}
	}
}