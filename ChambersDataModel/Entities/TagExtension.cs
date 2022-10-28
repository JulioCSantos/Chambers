using Chambers.Common;

namespace ChambersDataModel.Entities
{
    public partial class Tag
    {
        public Tag(int tagId, string tagName) : this() {
            TagId = tagId;
            TagName = tagName;
        }

        public Tag(string tagName) : this() {
            TagId = IntExtensions.NextId();
            TagName = tagName;
        }
    }
}
