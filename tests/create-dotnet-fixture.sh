#!/usr/bin/env bash
set -euo pipefail
root="${1:-$(mktemp -d /tmp/nvim-dotnet.XXXXXX)}"
mkdir -p "$root"
root="$(cd "$root" && pwd)"
dotnet new sln -n Validation -o "$root"
dotnet new classlib -n Library -o "$root/Library" --no-restore
dotnet new console -n App -o "$root/App" --no-restore
dotnet new xunit -n Tests -o "$root/Tests" --no-restore
dotnet sln "$root/Validation.slnx" add "$root/Library/Library.csproj" "$root/App/App.csproj" "$root/Tests/Tests.csproj"
dotnet add "$root/App/App.csproj" reference "$root/Library/Library.csproj"
dotnet add "$root/Tests/Tests.csproj" reference "$root/Library/Library.csproj"
cat > "$root/Library/Class1.cs" <<'CS'
namespace Library;
public static class Calculator
{
    public static int Add(int left, int right) => left + right;
}
CS
cat > "$root/App/Program.cs" <<'CS'
using Library;
var answer = Calculator.Add(20, 22);
Console.WriteLine(answer);
CS
cat > "$root/Tests/UnitTest1.cs" <<'CS'
using Library;
namespace Tests;
public class UnitTest1
{
    [Fact]
    public void Adds() => Assert.Equal(42, Calculator.Add(20, 22));
}
CS
dotnet build "$root/Validation.slnx"
dotnet test "$root/Validation.slnx" --no-build --no-restore
printf '\nFixture ready. Set NVIM_DOTNET_FIXTURE=%s\n' "$root"
