using Azure.Identity;
using Azure.Core;
using Microsoft.Fabric.Api;
using Microsoft.Fabric.Api.Core.Models;
using System.Text.Json;

const string Bold = "\x1b[1m";
const string Reset = "\x1b[0m";
const string Cyan = "\x1b[36m";
const string Yellow = "\x1b[33m";
const string Green = "\x1b[32m";
const string Red = "\x1b[31m";

Console.OutputEncoding = System.Text.Encoding.UTF8;

Console.WriteLine($"{Cyan}{Bold}");
Console.WriteLine("==========================================");
Console.WriteLine(" Welcome to Fabric Workspace Speedy Creator");
Console.WriteLine("==========================================");
Console.WriteLine(Reset);

Console.WriteLine();
Console.WriteLine($"{Yellow}Signing in...{Reset}");

var credential = new InteractiveBrowserCredential(new InteractiveBrowserCredentialOptions
{
    TokenCachePersistenceOptions = new TokenCachePersistenceOptions { Name = "FabricSpeedyCreator" }
});

var client = new FabricClient(credential);

// Get the authenticated user identity
string userIdentity = await GetUserIdentityAsync(credential);
Console.WriteLine($"{Green}✓ Signed in as: {userIdentity}{Reset}");

bool continueCreating = true;
while (continueCreating)
{
    string workspaceName = Prompt("Workspace name");

    Console.WriteLine($"{Yellow}Loading available capacities...{Reset}");
    var capacities = client.Core.Capacities.ListCapacities()
        .Where(c => c.State == CapacityState.Active)
        .OrderBy(c => c.DisplayName, StringComparer.OrdinalIgnoreCase)
        .ToList();

    if (capacities.Count == 0)
    {
        Console.WriteLine($"{Red}No active capacities are available for the signed-in user.{Reset}");
        break;
    }

    Console.WriteLine();
    Console.WriteLine($"{Bold}Available capacities:{Reset}");
    for (int i = 0; i < capacities.Count; i++)
    {
        var c = capacities[i];
        Console.WriteLine($"  [{i + 1}] {c.DisplayName}  ({c.Sku}, {c.Region})");
    }

    Capacity capacity = capacities[PromptChoice("Choose a capacity", capacities.Count) - 1];

    bool listAfter = PromptYesNo("List all workspaces after creation?");

    Console.WriteLine($"{Yellow}Creating workspace '{workspaceName}' on capacity '{capacity.DisplayName}' ({capacity.Id})...{Reset}");
    var request = new CreateWorkspaceRequest(workspaceName) { CapacityId = capacity.Id };
    var created = client.Core.Workspaces.CreateWorkspace(request).Value;
    Console.WriteLine($"{Green}Created workspace '{created.DisplayName}' (Id: {created.Id}).{Reset}");

    if (listAfter)
    {
        Console.WriteLine();
        Console.WriteLine($"{Bold}All workspaces:{Reset}");
        foreach (var ws in client.Core.Workspaces.ListWorkspaces())
        {
            bool isNew = ws.Id == created.Id;
            string line = $"  {ws.DisplayName}  ({ws.Id})";
            Console.WriteLine(isNew ? $"{Bold}{Green}{line}  <-- NEW{Reset}" : line);
        }
    }

    Console.WriteLine();
    continueCreating = PromptYesNo("Create another workspace?");
}

Console.WriteLine();
Console.WriteLine($"{Green}Goodbye!{Reset}");

static async Task<string> GetUserIdentityAsync(TokenCredential credential)
{
    try
    {
        // Get token to extract user information
        var tokenRequest = new TokenRequestContext(["https://graph.microsoft.com/.default"]);
        var token = await credential.GetTokenAsync(tokenRequest, CancellationToken.None);
        
        // Decode the JWT token to get user info
        var parts = token.Token.Split('.');
        if (parts.Length != 3) return "Unknown User";
        
        var payload = parts[1];
        // Add padding if necessary
        payload += new string('=', (4 - payload.Length % 4) % 4);
        
        var json = System.Text.Encoding.UTF8.GetString(Convert.FromBase64String(payload));
        using var doc = JsonDocument.Parse(json);
        var root = doc.RootElement;
        
        // Try to get user principal name or email
        if (root.TryGetProperty("upn", out var upnElement))
            return upnElement.GetString() ?? "Unknown User";
        
        if (root.TryGetProperty("email", out var emailElement))
            return emailElement.GetString() ?? "Unknown User";
            
        if (root.TryGetProperty("name", out var nameElement))
            return nameElement.GetString() ?? "Unknown User";
        
        return "Authenticated User";
    }
    catch
    {
        return "Authenticated User";
    }
}

static string Prompt(string label)
{
    while (true)
    {
        Console.Write($"{label}: ");
        var input = Console.ReadLine();
        if (!string.IsNullOrWhiteSpace(input)) return input.Trim();
        Console.WriteLine($"{Red}Value cannot be empty.{Reset}");
    }
}

static int PromptChoice(string label, int max)
{
    while (true)
    {
        Console.Write($"{label} [1-{max}]: ");
        var input = Console.ReadLine()?.Trim();
        if (int.TryParse(input, out int n) && n >= 1 && n <= max) return n;
        Console.WriteLine($"{Red}Please enter a number between 1 and {max}.{Reset}");
    }
}

static bool PromptYesNo(string label)
{
    while (true)
    {
        Console.Write($"{label} (y/n): ");
        var input = Console.ReadLine()?.Trim().ToLowerInvariant();
        if (input is "y" or "yes") return true;
        if (input is "n" or "no") return false;
        Console.WriteLine($"{Red}Please answer y or n.{Reset}");
    }
}

static void PressAnyKeyToExit()
{
    Console.WriteLine();
    Console.WriteLine("Press any key to exit...");
    Console.ReadKey(intercept: true);
}
