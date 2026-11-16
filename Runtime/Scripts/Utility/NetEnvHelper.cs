namespace Pico
{
	namespace Avatar
	{
		public static class NetEnvHelper
		{
			public const string SampleTokenApi = "/api/v2/avatar/editor/token";

			/// <summary>
			/// Get the API base URL for the region used by AvatarManager.
			/// Production and test environments use the same regional endpoints.
			/// </summary>
			/// <param name="providerName"></param>
			/// <returns></returns>
			public static string GetHostServer()
			{
				if (PicoAvatarApp.instance == null)
					return string.Empty;
				switch (PicoAvatarApp.instance.GetNationType())
				{
					case "cn":
						return "https://avatar.picovr.com";
					case "ttp":
						return "https://avatar-us.picoxr.us";
					default:
						return "https://avatar-sg.picoxr.com";
				}
			}

			public static string GetFullRequestUrl(string api)
			{
				return GetHostServer() + api;
			}
		}
	}
}
