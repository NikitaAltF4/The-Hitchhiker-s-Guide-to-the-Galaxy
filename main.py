import moderngl_window as mglw

class App(mglw.WindowConfig):
    window_size = 1920, 1080
    resource_dir = 'programs'

    def __init__(self, **kwargs):
        super().__init__(**kwargs)
        self.quad = mglw.geometry.quad_fs()
        self.program = self.load_program(vertex_shader='vertex.glsl', fragment_shader='fragment.glsl')
        self.u_scroll = 1.5
        #Текстуры
        self.texture1 = self.load_texture_2d('../textures/texture1.png') #Мыслитель
        self.texture2 = self.load_texture_2d('../textures/texture2.png') #Горы
        self.texture3 = self.load_texture_2d('../textures/16k_mars2.png') #Земля
        self.texture4 = self.load_texture_2d('../textures/postoment.jpg') #Основание
        self.texture5 = self.load_texture_2d('../textures/Tree.jpg')  #Ствол дерева
        self.texture6 = self.load_texture_2d('../textures/Ladder.jpg') #Листья
        self.texture7 = self.load_texture_2d('../textures/sky.jpg')  #Дневное небо
        self.texture8 = self.load_texture_2d('../textures/sky2.jpg')  #Ночное небо
        # uniforms
        self.program['u_scroll'] = self.u_scroll
        self.program['u_resolution'] = self.window_size
        self.program['u_texture1'] = 1
        self.program['u_texture2'] = 2
        self.program['u_texture3'] = 3
        self.program['u_texture4'] = 4
        self.program['u_texture5'] = 5
        self.program['u_texture6'] = 6
        self.program['u_texture7'] = 7
        self.program['u_texture8'] = 8

    def render(self, time, frame_time):
        self.ctx.clear()
        self.program['u_time'] = time
        self.texture1.use(location=1)
        self.texture2.use(location=2)
        self.texture3.use(location=3)
        self.texture4.use(location=4)
        self.texture5.use(location=5)
        self.texture6.use(location=6)
        self.texture7.use(location=7)
        self.texture8.use(location=8)
        self.quad.render(self.program)

    def mouse_position_event(self, x, y, dx, dy):
        self.program['u_mouse'] = (x, y);

    def mouse_scroll_event(self, x_offset, y_offset):
        self.u_scroll = max(1.0, self.u_scroll + y_offset)
        self.program['u_scroll'] = self.u_scroll

if __name__ == '__main__':
    mglw.run_window_config(App)
