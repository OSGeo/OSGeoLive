# Configuration file for jupyterhub.
 
from jupyterhub.spawner import LocalProcessSpawner
 
class MySpawner(LocalProcessSpawner):
    def user_env(self, env):
        env = super().user_env(env)
        env['GISRC'] = '/home/%s/.grass7/rc' % self.user.name
        return env
 
c = get_config()
 
c.JupyterHub.spawner_class = MySpawner
 
c.Spawner.notebook_dir = '~/jupyter'
 
c.JupyterHub.port = 8888 
 
c.JupyterHub.proxy_api_port = 9985
c.JupyterHub.hub_port = 9995
#c.JupyterHub.proxy_auth_token = ''
 
c.JupyterHub.admin_users = {'user'}
 
c.JupyterHub.config_file = '/usr/local/share/jupyter/jupyterhub_config.py'
 
#c.JupyterHub.data_files_path = '/usr/local/share/jupyter'
 
c.Spawner.env_keep = ['PATH', 'PYTHONPATH', 'LD_LIBRARY_PATH', 'GISBASE', 'GIS_LOCK', 'GISRC', 'GISDBASE','GRASS_RENDER_IMMEDIATE','GRASS_RENDER_FILE_COMPRESSION','GRASS_RENDER_WIDTH','GRASS_RENDER_HEIGHT','GRASS_RENDER_TRANSPARENT','GRASS_RENDER_FILE_READ','GRASS_RENDER_TRUECOLOR','GRASS_RENDER_PNG_AUTO_WRITE', 'LANG', 'LC_ALL']
 
c.JupyterHub.admin_users = {'user'}
c.JupyterHub.hub_ip = 'localhost'
