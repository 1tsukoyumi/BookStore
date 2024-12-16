import axios from "axios";

let auth = localStorage.getItem('auth');
if (auth == '') location = 'http://localhost:8080/login';

const instance = axios.create({
    baseURL: 'http://localhost:5021',
    headers: { Authorization: 'Bearer ' + auth }
});

instance.interceptors.request.use(function (config) {
    const token = localStorage.getItem("auth");
    if (token) {
        config.headers.Authorization = `Bearer ${token}`;
    } else {
        delete config.headers.Authorization;
    }
    return config;    
}, function (error) {
    // Do something with request error
    return Promise.reject(error);
});

// Add a response interceptor
instance.interceptors.response.use(function (response) {
    // Any status code that lie within the range of 2xx cause this function to trigger
    // Do something with response data
    return response;
}, function (error) {
    // Any status codes that falls outside the range of 2xx cause this function to trigger
    // Do something with response error
    return Promise.reject(error);
});

export default instance