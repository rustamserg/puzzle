package code
{
	import flash.display.MovieClip;
	
	public class Board extends MovieClip
	{
		private var m_board:DynamicMovie;
		private var m_data:Array = new Array(Config.boardSize*Config.boardSize);
		
		public static const E_OK:Number = 0;
		public static const E_OUT_OF_BOARD:Number = 1;
		public static const E_BUSY:Number = 2;
		
		public function Board()
		{
			for (var i:Number = 0; i < m_data.length; i++)
				m_data[i] = 1;
				
			m_board = FigureRender.renderFigure(m_data);
			addChild(m_board);
			m_board.setRegistration(0, 0);

			m_board.x2 = Config.boardPosX;
			m_board.y2 = Config.boardPosY;
			
			resetBoard();
		}
		
		public function get x2():Number
		{
			return m_board.x2;
		}
		
		public function get y2():Number
		{
			return m_board.y2;
		}
		
		public function set alpha2(value:Number):void
		{
			m_board.alpha = value;
		}
		
		public function resetBoard()
		{
			for (var i:Number = 0; i < m_data.length; i++)
				m_data[i] = 0;
		}
		
		public function checkFigure(stageX:Number, stageY:Number, dt:Array):Number
		{
			var rc:Number = E_OK;
			
			// adjust figure UL to board UL
			if (stageX < m_board.x && stageX > (m_board.x - Config.cellSize/2))
				stageX = m_board.x;
			
			if (stageY < m_board.y && stageY > (m_board.y - Config.cellSize/2))
				stageY = m_board.y;
			
			// check out of board case
			if (stageX < m_board.x || stageX > (m_board.x + m_board.width))
				return E_OUT_OF_BOARD;
				
			if (stageY < m_board.y || stageY > (m_board.y + m_board.height))
				return E_OUT_OF_BOARD;
				
			var xdb:Number = Math.floor((stageX - m_board.x)/Config.cellSize);
			var ydb:Number = Math.floor((stageY - m_board.y)/Config.cellSize);
					
			if ((stageX - m_board.x) % Config.cellSize >= Config.cellSize/2) xdb++;
			if ((stageY - m_board.y) % Config.cellSize >= Config.cellSize/2) ydb++;
					
			for (var ix:Number = 0; ix < Config.boardSize; ix++)
			{
				for (var iy:Number = 0; iy < Config.boardSize; iy++)
				{
					if (dt[iy*Config.boardSize + ix] == 1)
					{
						if ((xdb + ix) >= Config.boardSize || (ydb + iy) >=Config.boardSize) {
							rc = E_BUSY;
							break;
						}
						if (m_data[(ydb + iy)*Config.boardSize + (xdb + ix)] == 1) {
							rc = E_BUSY;
							break;
						}
					}
				}
			}
			return rc;
		}
		
		public function setFigure(figure:MovieClip, stageX:Number, stageY:Number, dt:Array):void
		{
			// adjust figure UL to board UL
			if (stageX < m_board.x && stageX > (m_board.x - Config.cellSize/2))
				stageX = m_board.x;
			
			if (stageY < m_board.y && stageY > (m_board.y - Config.cellSize/2))
				stageY = m_board.y;
			
			var xdb:Number = Math.floor((stageX - m_board.x)/Config.cellSize);
			var ydb:Number = Math.floor((stageY - m_board.y)/Config.cellSize);
					
			if ((stageX - m_board.x) % Config.cellSize >= Config.cellSize/2) xdb++;
			if ((stageY - m_board.y) % Config.cellSize >= Config.cellSize/2) ydb++;
					
			for (var ix:Number = 0; ix < Config.boardSize; ix++)
			{
				for (var iy:Number = 0; iy < Config.boardSize; iy++)
				{
					if (dt[iy*Config.boardSize + ix] == 1)
						m_data[(ydb + iy)*Config.boardSize + (xdb + ix)] = 1; 
				}
			}
			
			// set aligned to the board coordinate for the figure
			figure.x2 = xdb*Config.cellSize + m_board.x + Math.floor(figure.width/2);
			figure.y2 = ydb*Config.cellSize + m_board.y + Math.floor(figure.height/2);
			
			// check if all board has been filled
			checkBoard();
		}
		
		private function checkBoard():void
		{
			var bFilled:Boolean = true;
			
			for (var ix:Number = 0; ix < Config.boardSize && bFilled; ix++)
			{
				for (var iy:Number = 0; iy < Config.boardSize && bFilled; iy++)
				{
					if (m_data[iy*Config.boardSize + ix] == 0)
						bFilled = false;
				}
			}
			
			if (bFilled)
			{
				MovieClip(root).gotoAndPlay(20);
			}
		}
		
		public function clearFigure(stageX:Number, stageY:Number, dt:Array):void
		{
			var xdb:Number = Math.floor((stageX - m_board.x)/Config.cellSize);
			var ydb:Number = Math.floor((stageY - m_board.y)/Config.cellSize);
					
			if ((stageX - m_board.x) % Config.cellSize >= Config.cellSize/2) xdb++;
			if ((stageY - m_board.y) % Config.cellSize >= Config.cellSize/2) ydb++;
					
			for (var ix:Number = 0; ix < Config.boardSize; ix++)
			{
				for (var iy:Number = 0; iy < Config.boardSize; iy++)
				{
					if (dt[iy*Config.boardSize + ix] == 1)
						m_data[(ydb + iy)*Config.boardSize + (xdb + ix)] = 0; 
				}
			}
		}
	}
}