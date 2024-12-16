import { createRouter, createWebHistory } from 'vue-router';
import LoginComponent from '../components/login.vue';
import TacGiaComponent from '../components/tac-gia.vue';
import TheLoaiComponent from '../components/the-loai.vue'
import HoaDonComponent from '../components/hoa-don.vue';
import HomeComponent from '../components/home.vue';
import SachComponent from '../components/sach.vue';

const routes = [
    {
        path: '/home',
        name: 'HomeComponent',
        component: HomeComponent,
        meta: { requiresAuth: true }
    },
    {
        path: '/login',
        name: 'LoginComponent',
        component: LoginComponent
    },
    {
        path: '/san-pham',
        name: 'SachComponent',
        component: SachComponent
    },
    {
        path: '/tac-gia',
        name: 'TacGiaComponent',
        component: TacGiaComponent,
        meta: { requiresAuth: true }
    },
    {
        path: '/the-loai',
        name: 'TheLoaiComponent',
        component: TheLoaiComponent,
        meta: { requiresAuth: true }
    },
    {
        path: '/hoa-don',
        name: 'HoaDonComponent',
        component: HoaDonComponent,
        meta: { requiresAuth: true }
    },
    {
        path: '/:pathMatch(.*)*',
        redirect: '/login',
    }
];

const router = createRouter({
    history: createWebHistory(),
    routes,
});

// Middleware kiểm tra đăng nhập
router.beforeEach((to, from, next) => {
    const isAuthenticated = localStorage.getItem('auth'); // Hoặc kiểm tra token từ store

    if (to.meta.requiresAuth && !isAuthenticated) {
        // Nếu cần đăng nhập mà chưa đăng nhập, điều hướng về trang login
        next();
    } else {
        // Nếu đã đăng nhập hoặc không cần bảo mật, cho phép điều hướng
        next();
    }
});

export default router;