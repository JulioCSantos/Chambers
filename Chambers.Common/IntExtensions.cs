namespace Chambers.Common
{
    public static class IntExtensions
    {
        #region NextId

        private static int _id = 100;
        public static Func<int> NextId = () => { Interlocked.Increment(ref _id); return _id; };
        #endregion NextId
    }
}