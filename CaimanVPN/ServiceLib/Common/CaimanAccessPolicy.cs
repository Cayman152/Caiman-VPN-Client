namespace ServiceLib.Common;

public static class CaimanAccessPolicy
{
    // Keep exact hosts/IPs in one place to simplify future updates.
    private static readonly HashSet<string> AllowedExactHosts = new(StringComparer.OrdinalIgnoreCase)
    {
        "5.34.214.238",
        "77.73.70.240",
        "169.40.4.196"
    };

    private static readonly string[] AllowedHostKeywords =
    [
        "caiman",
        "cayman"
    ];

    public static bool IsProfileAllowed(ProfileItem? profileItem)
    {
        if (profileItem is null)
        {
            return false;
        }

        if (profileItem.ConfigType.IsGroupType())
        {
            return true;
        }

        if (profileItem.ConfigType == EConfigType.Custom)
        {
            return profileItem.IsSub && profileItem.Subid.IsNotEmpty();
        }

        return IsServerHostAllowed(profileItem.Address);
    }

    public static bool IsSubscriptionUrlAllowed(string? url)
    {
        if (url.IsNullOrEmpty())
        {
            return false;
        }

        var uri = Utils.TryUri(url.TrimEx());
        if (uri is null)
        {
            return false;
        }

        return IsServerHostAllowed(uri.IdnHost);
    }

    public static bool AreSubscriptionUrlsAllowed(string? rawUrls)
    {
        if (rawUrls.IsNullOrEmpty())
        {
            return true;
        }

        foreach (var url in rawUrls.Split([',', ';', '\r', '\n', '\t', ' '], StringSplitOptions.RemoveEmptyEntries))
        {
            if (!IsSubscriptionUrlAllowed(url.TrimEx()))
            {
                return false;
            }
        }

        return true;
    }

    public static bool IsServerHostAllowed(string? addressOrHost)
    {
        var host = NormalizeHost(addressOrHost);
        if (host.IsNullOrEmpty())
        {
            return false;
        }

        if (host.Equals("localhost", StringComparison.OrdinalIgnoreCase)
            || host.Equals(Global.Loopback, StringComparison.OrdinalIgnoreCase)
            || host.Equals("::1", StringComparison.OrdinalIgnoreCase))
        {
            return true;
        }

        if (AllowedExactHosts.Contains(host))
        {
            return true;
        }

        return AllowedHostKeywords.Any(keyword => host.Contains(keyword, StringComparison.OrdinalIgnoreCase));
    }

    private static string NormalizeHost(string? addressOrHost)
    {
        if (addressOrHost.IsNullOrEmpty())
        {
            return string.Empty;
        }

        var value = addressOrHost.TrimEx();
        if (value.IsNullOrEmpty())
        {
            return string.Empty;
        }

        if (value.StartsWith("[", StringComparison.Ordinal) && value.Contains(']'))
        {
            var close = value.IndexOf(']');
            if (close > 1)
            {
                return value[1..close].Trim().Trim('.');
            }
        }

        if (value.Contains("://", StringComparison.Ordinal) && Utils.TryUri(value) is Uri uri)
        {
            return uri.IdnHost.Trim().Trim('.');
        }

        if (value.Contains('/'))
        {
            value = value.Split('/', 2, StringSplitOptions.RemoveEmptyEntries).FirstOrDefault() ?? value;
        }

        if (value.Count(ch => ch == ':') == 1 && value.Contains('.'))
        {
            value = value.Split(':', 2)[0];
        }

        return value.Trim().Trim('.');
    }
}
