using Microsoft.Owin;
using Owin;

[assembly: OwinStartupAttribute(typeof(DoAnLTW.Startup))]
namespace DoAnLTW
{
    public partial class Startup
    {
        public void Configuration(IAppBuilder app)
        {
            ConfigureAuth(app);
        }
    }
}
