@echo off
set batdir=%~dp0
pushd "%batdir%"

echo You are about to create a dotnet core WebApi project based on Clean Architecture
set /p cont="Do you want to continue [Y/N]:"

if not %cont%==Y exit

%= ----------Project configuration---------- =%
set /p enteredprojectname="Please enter project name:"
set projectname=%enteredprojectname%
set dotnetclipresentationlayerprojectname=webapi
set presentationlayerprojectname=WebApi
set targetframework=netcoreapp3.1
%= ----------Project configuration---------- =%

%= ----------Nuget packages---------- =%
set newtonsoft=Newtonsoft.Json
set newtonsoftversion=12.0.2

set swashbuckle=Swashbuckle.AspNetCore
set swashbuckleversion=5.0.0-rc3

set mvcversioning=Microsoft.AspNetCore.Mvc.Versioning
set mvcversioningversion=4.0.0-preview8.19405.7

set mvcversioningapiexplorer=Microsoft.AspNetCore.Mvc.Versioning.ApiExplorer
set mvcversioningapiexplorerversion=4.0.0-preview8.19405.7

set codegeneration=Microsoft.VisualStudio.Web.CodeGeneration.Design
set codegenerationversion=3.0.0

set mediatr=MediatR
set mediatrversion=7.0.0

set mediatrdependencyinjection=MediatR.Extensions.Microsoft.DependencyInjection
set mediatrdependencyinjectionversion=7.0.0

%= ----------Nuget packages---------- =%

%= --------------------------------------------------Process starts-------------------------------------------------- =%

set texttransformexe=%batdir%Utility\T4CmdLineHost\TextTransform.exe
set csprojupdateexe=%batdir%Utility\CsProjUpdate\CsProjUpdate.exe
set t4templatepath=%batdir%Utility\T4Templates\DotNetCoreWebApi

%= Create a directory with the project's name =%
md %projectname%

%= Change to the created directory =%
cd %projectname%

%= Create solution file with the project's name =%
dotnet new sln --name %projectname%

%= Create the Src directory =%
md Src

%= Change to the Src directory =%
cd Src

%= Create the Common directory =%
md Common

%= Change to the Common directory =%
cd Common

%= Create the class libraries in ***Common folder*** =%
dotnet new classlib -o %projectname%.Common -f %targetframework%
cd %projectname%.Common

md References
%texttransformexe% -a=targetFramework!%targetframework% -o %projectname%.Common.csproj %t4templatepath%\CommonCsproj.tt

del Class1.cs

%texttransformexe% -a=nameSpace!%projectname%.Common -o Constants.cs %t4templatepath%\CommonConstants.tt
%texttransformexe% -a=nameSpace!%projectname%.Common -o Enums.cs %t4templatepath%\CommonEnums.tt
%texttransformexe% -a=nameSpace!%projectname%.Common -o Utility.cs %t4templatepath%\CommonUtility.tt

cd ..
%= Create the class libraries in ***Common folder*** =%

%= Come out of the Common directory =%
cd..

%= Create the Core directory =%
md Core

%= Change to the Core directory =%
cd Core

%= Create the class libraries in ***Core folder*** =%
dotnet new classlib -o %projectname%.Domain -f %targetframework%
dotnet add %projectname%.Domain package %newtonsoft% --version %newtonsoftversion%

cd %projectname%.Domain
del Class1.cs

%texttransformexe% -a=nameSpace!%projectname%.Domain -o ExampleRequest.cs %t4templatepath%\ExampleRequest.tt
%texttransformexe% -a=nameSpace!%projectname%.Domain -o ResponseMessage.cs %t4templatepath%\ResponseMessage.tt
%texttransformexe% -a=nameSpace!%projectname%.Domain -o ValidationError.cs %t4templatepath%\ValidationError.tt

cd..

dotnet new classlib -o %projectname%.Application -f %targetframework%
dotnet add %projectname%.Application package %mediatr% --version %mediatrversion%

cd %projectname%.Application
del Class1.cs

%texttransformexe% -a=nameSpace!%projectname%.Application -o ExampleRequestQuery.cs %t4templatepath%\ExampleRequestQuery.tt
%texttransformexe% -a=nameSpace!%projectname%.Application -o ExampleRequestQueryHandler.cs %t4templatepath%\ExampleRequestQueryHandler.tt

cd..
%= Create the class libraries in ***Core folder*** =%

%= Come out of the Core directory =%
cd..

%= Create the Infrastructure directory =%
md Infrastructure

%= Change to the Infrastructure directory =%
cd Infrastructure

%= Create the class libraries in ***Infrastructure folder*** =%
dotnet new classlib -o %projectname%.Persistence -f %targetframework%
dotnet add %projectname%.Persistence package %newtonsoft% --version %newtonsoftversion%
dotnet new classlib -o %projectname%.Infrastructure -f %targetframework%
dotnet add %projectname%.Infrastructure package %newtonsoft% --version %newtonsoftversion%
%= Create the class libraries in ***Infrastructure folder*** =%

%= Come out of the Infrastructure directory =%
cd..

%= Create the Presentation directory =%
md Presentation

%= Change to the Presentation directory =%
cd Presentation

%= Create project in ***Presentation folder*** =%
dotnet new %dotnetclipresentationlayerprojectname% -o %projectname%.%presentationlayerprojectname% -f %targetframework%
dotnet add %projectname%.%presentationlayerprojectname% package %swashbuckle% --version %swashbuckleversion%
dotnet add %projectname%.%presentationlayerprojectname% package %mvcversioning% --version %mvcversioningversion%
dotnet add %projectname%.%presentationlayerprojectname% package %mvcversioningapiexplorer% --version %mvcversioningapiexplorerversion%
dotnet add %projectname%.%presentationlayerprojectname% package %codegeneration% --version %codegenerationversion%
dotnet add %projectname%.%presentationlayerprojectname% package %mediatr% --version %mediatrversion%
dotnet add %projectname%.%presentationlayerprojectname% package %mediatrdependencyinjection% --version %mediatrdependencyinjectionversion%

cd %projectname%.%presentationlayerprojectname%
dotnet tool install -g dotnet-aspnet-codegenerator
%texttransformexe% -a=nameSpace!%projectname%.%presentationlayerprojectname% -o Startup.cs %t4templatepath%\PresentationStartup.tt
cd Properties
%texttransformexe% -o launchSettings.json %t4templatepath%\PresentationLaunchSettings.tt
cd..
dotnet aspnet-codegenerator controller -name SwaggerCustomJs -actions -api -outDir wwwroot\swagger
cd wwwroot\swagger
del SwaggerCustomJsController.cs
%texttransformexe% -o swaggercustom.js %t4templatepath%\SwaggerCustomJs.tt
cd..
cd..
dotnet aspnet-codegenerator controller -name ExampleV1Controller -actions -api -outDir Controllers\V1
del WeatherForecast.cs
cd controllers
del WeatherForecastController.cs
cd v1
%texttransformexe% -a=nameSpace!%projectname%.%presentationlayerprojectname%.Controllers.V1 -o ExampleV1Controller.cs %t4templatepath%\PresentationExampleV1Controller.tt
cd..
cd..
cd..
%= Create project in ***Presentation folder*** =%

%= Come out of the Presentation directory =%
cd..

%= Come out of the Src directory =%
cd..

%= Add projects to solution =%
dotnet sln %projectname%.sln add .\Src\Presentation\%projectname%.%presentationlayerprojectname%\%projectname%.%presentationlayerprojectname%.csproj .\Src\Common\%projectname%.Common\%projectname%.Common.csproj  .\Src\Core\%projectname%.Domain\%projectname%.Domain.csproj .\Src\Core\%projectname%.Application\%projectname%.Application.csproj .\Src\Infrastructure\%projectname%.Persistence\%projectname%.Persistence.csproj .\Src\Infrastructure\%projectname%.Infrastructure\%projectname%.Infrastructure.csproj
%= Add projects to solution =%

%= Add references to projects =%
%= Core =%
dotnet add .\Src\Core\%projectname%.Domain\%projectname%.Domain.csproj reference .\Src\Common\%projectname%.Common\%projectname%.Common.csproj
dotnet add .\Src\Core\%projectname%.Application\%projectname%.Application.csproj reference .\Src\Core\%projectname%.Domain\%projectname%.Domain.csproj

%= Infrastructure =%
dotnet add .\Src\Infrastructure\%projectname%.Persistence\%projectname%.Persistence.csproj reference .\Src\Core\%projectname%.Domain\%projectname%.Domain.csproj
dotnet add .\Src\Infrastructure\%projectname%.Infrastructure\%projectname%.Infrastructure.csproj reference .\Src\Core\%projectname%.Domain\%projectname%.Domain.csproj

%= Presentation =%
dotnet add .\Src\Presentation\%projectname%.%presentationlayerprojectname%\%projectname%.%presentationlayerprojectname%.csproj reference .\Src\Core\%projectname%.Domain\%projectname%.Domain.csproj
dotnet add .\Src\Presentation\%projectname%.%presentationlayerprojectname%\%projectname%.%presentationlayerprojectname%.csproj reference .\Src\Core\%projectname%.Application\%projectname%.Application.csproj
dotnet add .\Src\Presentation\%projectname%.%presentationlayerprojectname%\%projectname%.%presentationlayerprojectname%.csproj reference .\Src\Infrastructure\%projectname%.Infrastructure\%projectname%.Infrastructure.csproj
%= Add references to projects =%

%= Create the Test directory =%
md Test

%= Change to the Test directory =%
cd Test

%= Create unit test in ***Test folder*** =%
dotnet new xunit -o %projectname%.Application.Test -f %targetframework%
dotnet new xunit -o %projectname%.Persistence.Test -f %targetframework%
dotnet new xunit -o %projectname%.Infrastructure.Test -f %targetframework%
%= Create unit test in ***Test folder*** =%

%= Come out of the Test directory =%
cd..

%= Add unit test projects to solution =%
dotnet sln %projectname%.sln add .\Test\%projectname%.Application.Test\%projectname%.Application.Test.csproj  .\Test\%projectname%.Persistence.Test\%projectname%.Persistence.Test.csproj .\Test\%projectname%.Infrastructure.Test\%projectname%.Infrastructure.Test.csproj
%= Add unit test projects to solution =%

%= Add references =%
dotnet add .\Test\%projectname%.Persistence.Test\%projectname%.Persistence.Test.csproj reference .\Src\Infrastructure\%projectname%.Persistence\%projectname%.Persistence.csproj
dotnet add .\Test\%projectname%.Infrastructure.Test\%projectname%.Infrastructure.Test.csproj reference .\Src\Infrastructure\%projectname%.Infrastructure\%projectname%.Infrastructure.csproj
dotnet add .\Test\%projectname%.Application.Test\%projectname%.Application.Test.csproj reference .\Src\Core\%projectname%.Application\%projectname%.Application.csproj
%= Add references =%
pause

%= --------------------------------------------------Process ends-------------------------------------------------- =%
