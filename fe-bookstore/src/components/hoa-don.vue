<template>
    <div class="text-center my-3">
        <div class="mb-2"><b>DANH SÁCH HÓA ĐƠN</b></div>
        <v-btn elevation="0" color="success" @click="openDialogUpdateHoaDon(null)">
            Thêm mới
        </v-btn>
    </div>

    <div v-if="errorMessage != ''" class="mt-2 mb-2 text-center" :style="{ color: colorMessage }">
        <b>{{ errorMessage }}</b>
    </div>

    <v-table style="width: 50%" class="mx-auto">
        <thead>
            <tr>
                <th> Mã HD </th>
                <th class="text-left"> Tên user </th>
                <th class="text-left"> Ngày lập</th>
                <th class="text-left"> Thành tiền </th>
                <th> Xem </th>
                <th> Xoá </th>
            </tr>
        </thead>
        <tbody>
            <tr v-for="item in dataHoaDon" :key="item.maHD">
                <td>{{ item.MaHoaDon }}</td>
                <td>{{ item.Username }}</td>
                <td>{{ item.OrderDate }}</td>
                <td>{{ item.ThanhTien }}</td>
                <td>
                    <v-icon color="blue" style="background-color: greenyellow;" @click="viewHoaDonDetails(item)">mdi-eye</v-icon>
                </td>
                <td><v-icon style="background-color: red;" @click="showDialogDeleteConfirm(item)">mdi-delete</v-icon></td>
            </tr>
        </tbody>
    </v-table>

    <v-dialog v-model="showDialogDetails" width="40%">
        <v-card title="Chi tiết hóa đơn">
            <v-table>
                <thead>
                    <tr>
                        <th>Tên sách</th>
                        <th>Số lượng</th>
                        <th>Thành tiền</th>
                    </tr>
                </thead>
                <tbody>
                    <tr v-for="item in orderDetails" :key="item.MaSach">
                        <td>{{ item.TenSach }}</td>
                        <td>{{ item.SoLuong }}</td>
                        <td>{{ item.ThanhTien }}</td>
                    </tr>
                </tbody>
            </v-table>
            <v-card-actions>
                <v-spacer></v-spacer>
                <v-btn text="Đóng" @click="showDialogDetails = false"></v-btn>
            </v-card-actions>
        </v-card>
    </v-dialog>


    <!-- Hộp thoại Thêm, sửa dữ liệu -->
    <v-dialog width="40%" scrollable v-model="showDialogUpdate">
        <template v-slot:default="{ isActive }">
            <v-card prepend-icon="mdi-earth" :title="dialogUpdateTitle">
                <v-divider class="mb-3"></v-divider>

                <v-card-text class="px-4">
                    <v-select v-model="selectedBook.MaSach" :items="booksList" item-title="TenSach" item-value="MaSach"
                        label="Chọn sách" variant="outlined"></v-select>
                    <v-text-field v-model="selectedBook.SoLuong" label="Số lượng" variant="outlined"
                        type="number"></v-text-field>
                    <v-btn color="success" @click="addBookToOrder()">Thêm vào hóa đơn</v-btn>
                </v-card-text>

                <v-table class="mt-3">
                    <thead>
                        <tr>
                            <th>Tên sách</th>
                            <th>Số lượng</th>
                            <th>Xóa</th>
                        </tr>
                    </thead>
                    <tbody>
                        <tr v-for="(book, index) in orderDetails" :key="index">
                            <td>{{ book.TenSach }}</td>
                            <td>{{ book.SoLuong }}</td>
                            <td>
                                <v-icon color="red" @click="removeBookFromOrder(index)">mdi-delete</v-icon>
                            </td>
                        </tr>
                    </tbody>
                </v-table>

                <v-divider></v-divider>

                <v-card-actions>
                    <v-btn text="ĐÓNG" @click="isActive.value = false"></v-btn>
                    <v-spacer></v-spacer>
                    <v-btn color="surface-variant" text="LƯU" variant="flat" @click="saveUpdateAction()"></v-btn>
                </v-card-actions>
            </v-card>
        </template>
    </v-dialog>

    <!-- Hộp thoại xác nhận xóa -->
    <v-dialog v-model="showDialogDelete" max-width="400px">
        <v-card>
            <v-card-title class="headline">Xác nhận xoá</v-card-title>
            <v-divider class="mb-4"></v-divider>
            <v-card-text class="text-center">
                Bạn có chắc xoá dữ liệu không?
            </v-card-text>
            <v-card-actions>
                <v-spacer></v-spacer>
                <v-btn color="blue" text @click="showDialogDelete = false">Huỷ</v-btn>
                <v-btn color="red" text @click="deleteAction()">Đồng ý</v-btn>
            </v-card-actions>
        </v-card>
    </v-dialog>

</template>
<script>
import axios from '../utils/axios'
export default {
    name: 'HoaDonComponent',
    data: () => ({
        dataHoaDon: [],
        showDialogUpdate: false,
        showDialogDelete: false,
        dialogUpdateTitle: "",
        errorMessage: "",
        colorMessage: "blue",
        booksList: [],
        // Chi tiết hóa đơn tạm thời
        orderDetails: [],
        // Dữ liệu sách đang chọn
        selectedBook: {
            MaSach: null,
            SoLuong: 1,
            TenSach: ""
        },
        showDialogDetails: false,
    }),
    mounted() {
        this.getHoaDon();
        this.getBooksList();
    },
    methods: {
        viewHoaDonDetails(obj) {
            axios.get(`/HoaDon/${obj.MaHoaDon}`)
                .then(response => {
                    this.orderDetails = response.data.data;
                    this.showDialogDetails = true;
                })
                .catch(error => {
                    this.errorMessage = error.response.data.message;
                    this.colorMessage = "red";
                });
        },
        getBooksList() {
            axios.get('/Sach', {})
                .then((response) => { this.booksList = [...response.data.data] })
                .catch((error) => { console.log(error); });
        },
        addBookToOrder() {
            if (!this.selectedBook.MaSach || this.selectedBook.SoLuong <= 0) return;

            const book = this.booksList.find(b => b.MaSach === this.selectedBook.MaSach);
            if (book) {
                this.orderDetails.push({
                    MaSach: book.MaSach,
                    TenSach: book.TenSach,
                    SoLuong: this.selectedBook.SoLuong
                });
                // Reset selected book
                console.log(book);
                this.selectedBook = { MaSach: null, SoLuong: 1 };
            }
        },
        removeBookFromOrder(index) {
            this.orderDetails.splice(index, 1);
        },
        // Lấy danh sách hóa đơn
        getHoaDon() {
            axios.get('/HoaDon', {})
                .then((response) => { this.dataHoaDon = [...response.data.data] })
                .catch((error) => { console.log(error); });
        },

        // Mở hộp thoại thêm hoặc sửa thông tin hóa đơn
        openDialogUpdateHoaDon(obj) {
            this.showDialogUpdate = true;
            if (obj == null) {
                this.dialogUpdateTitle = "Thêm mới hóa đơn";
                this.orderDetails = [];
            }
            else {
                this.dialogUpdateTitle = "Chỉnh sửa thông tin hóa đơn";
                this.objHoaDon.MaHD = obj.MaHD;
                this.objHoaDon.TenHoaDon = obj.TenHoaDon;
            }
        },

        // Thực hiện thao tác thêm hoặc chỉnh sửa thông tin
        saveUpdateAction() {
            if (this.orderDetails.length === 0) {
                this.errorMessage = "Vui lòng thêm sách vào hóa đơn.";
                this.colorMessage = "red";
                return;
            }

            axios.post('/HoaDon', {
                UserID: 1,
                OrderDetails: this.orderDetails.map(book => ({
                    MaSach: book.MaSach,
                    SoLuong: book.SoLuong,
                    GiaBan: 0 // Giả sử backend sẽ xử lý giá bán
                }))
            })
                .then(response => {
                    this.showDialogUpdate = false;
                    this.getHoaDon();
                    this.errorMessage = response.data.message;
                    this.colorMessage = "blue";
                })
                .catch(error => {
                    this.errorMessage = error.response.data.message;
                    this.colorMessage = "red";
                    this.showDialogUpdate = false;
                });
        },

        // Hiển thị hộp thoại Confirm trước khi xoá
        showDialogDeleteConfirm(obj) {
            this.objHoaDon.MaHD = obj.MaHD;
            this.objHoaDon.TenHoaDon = obj.TenHoaDon;

            this.showDialogDelete = true;
        },

        // Xoá dữ liệu
        deleteAction() {
            axios.post('/HoaDon/delete',
                {
                    MaHD: this.objHoaDon.MaHD
                })
                .then((response) => {
                    this.getHoaDon();
                    this.showDialogDelete = false;
                    this.errorMessage = response.data.message;
                    this.colorMessage = "blue";
                })
                .catch((error) => {
                    this.errorMessage = error.response.data.message;
                    this.colorMessage = "red";
                    this.showDialogDelete = false;
                });
        },
    }
}
</script>