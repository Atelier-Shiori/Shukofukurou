using System;
using Foundation;
using AppKit;
namespace MALLibrary
{
	[Register("SeasonTypeConvert")]
	public class SeasonTypeConvert : NSValueTransformer
	{
		public override NSObject TransformedValue(NSObject value)
		{
			if (value == null)
			{
				return null;
			}
				NSString s = new NSString();
				switch ((NSString)value.ToString())
				{
					case "1":
						s = (NSString)"TV";
						break;
					case "2":
						s = (NSString)"OVA";
						break;
					case "3":
						s = (NSString)"Movie";
						break;
					case "4":
						s = (NSString)"Special";
						break;
					case "5":
						s = (NSString)"ONA";
						break;
					case "6":
						s = (NSString)"Music";
						break;

				}
				return s;
		}
	}
}
