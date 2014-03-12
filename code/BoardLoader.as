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
			/*var requestGet:URLRequest = new URLRequest("http://plainx.com/andrey/gen.php");
			var loaderGet:URLLoader = new URLLoader();
			var variablesGet:URLVariables = new URLVariables();

			variablesGet.board = Config.boardSize;
			variablesGet.minc = Config.minCells;
			variablesGet.maxc = Config.maxCells;

			requestGet.data = variablesGet;
			requestGet.method = URLRequestMethod.POST;

			loaderGet.dataFormat = URLLoaderDataFormat.VARIABLES;
			loaderGet.addEventListener(Event.COMPLETE, loaderGetCompleteHandler);
			
			loaderGet.load(requestGet);*/
			createPuzzle(null);
		}
	
		private function loaderGetCompleteHandler(event:Event):void
		{
			/*var loader:URLLoader = URLLoader(event.target);
    		var vars:URLVariables = new URLVariables(loader.data);
			if (vars.board != "")
			{
				var str:String = vars.board;
				var matrix:Array = str.split(",", Config.boardSize*Config.boardSize);
				createPuzzle(matrix);
			}*/
		}

		private function createPuzzle(matrix:Array):void
		{
			// here we fill test board matrix ///////////////
			// in future it should be replaced by 
			var matrix:Array = new Array();
			
			if (Config.puzzleLevel == 2)
			{
				matrix = [1, 1, 7, 7, 8, 8,
							1, 1, 7, 7, 8, 8,
					  		2, 3, 3, 7, 4, 4,
					  		2, 3, 3, 7, 6, 4,
					  		2, 3, 5, 5, 6, 4,
					  		2, 5, 5, 5, 6, 6];
			}
			else if (Config.puzzleLevel == 1)
			{
				matrix = [1, 1, 7, 7, 8, 8, 8, 8,
							1, 1, 7, 7, 8, 8, 8, 8,
					  		2, 3, 3, 7, 4, 4, 4, 4,
					  		2, 3, 3, 7, 6, 4, 4, 4,
					  		2, 3, 5, 5, 6, 4, 4, 4,
							2, 3, 5, 5, 6, 4, 4, 4,
							2, 3, 5, 5, 6, 4, 4, 4,
					  		2, 5, 5, 5, 6, 6, 6, 6];
			}
			else
			{
				matrix = [1, 1, 7, 7, 8, 8, 8, 8, 8, 8,
							1, 1, 7, 7, 8, 8, 8, 8, 8, 8,
							1, 1, 7, 7, 8, 8, 8, 8, 8, 8,
							1, 1, 7, 7, 8, 8, 8, 8, 8, 8,
					  		2, 3, 3, 7, 4, 4, 4, 4, 4, 4,
					  		2, 3, 3, 7, 6, 4, 4, 4, 4, 4,
					  		2, 3, 5, 5, 6, 4, 4, 4, 4, 4,
							2, 3, 5, 5, 6, 4, 4, 4, 4, 4,
							2, 3, 5, 5, 6, 4, 4, 4, 4, 4,
					  		2, 5, 5, 5, 6, 6, 6, 6, 6, 6];
			}
			////////////////////////////////////////////////

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
	}
}