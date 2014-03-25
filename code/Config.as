package code
{
	dynamic public class Config extends Object
	{
		public static function get cellSize():Number
		{
			return m_cellSize[puzzleLevel];
		}
		
		public static function get boardSize():Number
		{
			return m_boardSize[puzzleLevel];
		}
		
		public static function get scoreDelay():Number
		{
			return m_scoreDelay[puzzleLevel];
		}
		
		public static function get boardCells():Number
		{
			return m_boardCells[puzzleLevel];
		}
		
		private static var m_cellSize:Array = [30, 40, 50];
		private static var m_boardSize:Array = [10, 8, 6];
		private static var m_boardCells:Array = [12, 9, 7];
		private static var m_scoreDelay:Array = [5000, 3000, 1000];
		
		public static var puzzleLevel:Number = 0;
		public static var boardPosX:Number = 30;
		public static var boardPosY:Number = 50;
	}
}