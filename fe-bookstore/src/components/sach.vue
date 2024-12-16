<template>
    <div class="text-center my-3">
        <div class="mb-2"><b>DANH SÁCH SẢN PHẨM</b></div>
        <v-btn elevation="0" color="success" @click="openDialogUpdateSach(null)">
            Thêm mới
        </v-btn>
    </div>

    <div v-if="errorMessage != ''" class="mt-2 mb-2 text-center" :style="{ color: colorMessage }">
        <b>{{ errorMessage }}</b>
    </div>

    <v-table style="width: 80%" class="mx-auto">
        <thead>
            <tr>
                <th> Mã sách </th>
                <th class="text-left"> Tên sách </th>
                <th class="text-left"> Thể loại </th>
                <th class="text-left"> Tác giả </th>
                <th class="text-left"> Số lượng tồn </th>
                <th class="text-left"> Giá bán </th>
                <th class="text-left"> Ảnh bìa </th>
                <th> Sửa </th>
                <th> Xoá </th>
            </tr>
        </thead>
        <tbody>
            <tr v-for="item in dataSach" :key="item.MaSach">
                <td>{{ item.MaSach }}</td>
                <td>{{ item.TenSach }}</td>
                <td>{{ item.TenTheLoai }}</td>
                <td>{{ item.TenTacGia }}</td>
                <td>{{ item.SoLuongTon }}</td>
                <td>{{ item.GiaBan }}</td>
                <td>{{ item.AnhBia }}</td>
                <td><v-icon style="background-color: greenyellow; "
                        @click="openDialogUpdateSach(item)">mdi-pencil</v-icon></td>
                <td><v-icon style="background-color: red; " @click="showDialogDeleteConfirm(item)">mdi-delete</v-icon>
                </td>
            </tr>
        </tbody>
    </v-table>

    <!-- Hộp thoại Thêm, sửa dữ liệu -->
    <v-dialog width="50%" scrollable v-model="showDialogUpdate">
        <template v-slot:default="{ isActive }">
            <v-card prepend-icon="mdi-earth" :title="dialogUpdateTitle">
                <v-divider class="mb-3"></v-divider>

                <v-card-text class="px-4">
                    <v-text-field v-model="objSach.TenSach" label="Tên sách" variant="outlined"></v-text-field>
                </v-card-text>
                <v-card-text class="px-4">
                    <v-text-field v-model="objSach.MaTacGia" label="Mã tác giả" variant="outlined"></v-text-field>
                </v-card-text>
                <v-card-text class="px-4">
                    <v-text-field v-model="objSach.MaTheLoai" label="Mã thể loại" variant="outlined"></v-text-field>
                </v-card-text>
                <v-card-text class="px-4">
                    <v-text-field v-model="objSach.SoLuongTon" label="Số lượng tồn" variant="outlined"></v-text-field>
                </v-card-text>
                <v-card-text class="px-4">
                    <v-text-field v-model="objSach.GiaBan" label="Giá bán" variant="outlined"></v-text-field>
                </v-card-text>
                <v-card-text class="px-4">
                    <v-text-field v-model="objSach.AnhBia" label="Ảnh bìa" variant="outlined"></v-text-field>
                </v-card-text>

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
    name: 'SachComponent',
    data: () => ({
        dataSach: [],
        showDialogUpdate: false,
        showDialogDelete: false,
        dialogUpdateTitle: "",
        objSach: {
            MaSach: 0,
            TenSach: "",
            MaTacGia: 0,
            TenTacGia: "",
            MaTheLoai: 0,
            TenTheLoai: "",
            GiaBan: 0,
            SoLuongTon: 0,
            MoTa: "",
            AnhBia: ""
        },
        errorMessage: "",
        colorMessage: "blue"
    }),
    mounted() {
        this.getSach()
    },
    methods: {
        // Lấy danh sách sách
        getSach() {
            axios.get('/Sach', {})
                .then((response) => { this.dataSach = [...response.data.data] })
                .catch((error) => { console.log(error); });
        },

        // Mở hộp thoại thêm hoặc sửa thông tin sách
        openDialogUpdateSach(obj) {
            this.showDialogUpdate = true;
            if (obj == null) {
                this.dialogUpdateTitle = "Thêm mới sách";
                this.objSach.MaSach = 0;
                this.objSach.TenSach = "";
                this.objSach.MaTacGia = 0;
                this.objSach.MaTheLoai = 0;
                this.objSach.GiaBan = 0;
                this.objSach.SoLuongTon = 0;
                this.objSach.MoTa = "";
                this.objSach.AnhBia = "";
            }
            else {
                this.dialogUpdateTitle = "Chỉnh sửa thông tin sách";
                this.objSach.MaSach = obj.MaSach;
                this.objSach.TenSach = obj.TenSach;
                this.objSach.MaTacGia = obj.MaTacGia;
                this.objSach.MaTheLoai = obj.MaTheLoai;
                this.objSach.GiaBan = obj.GiaBan;
                this.objSach.SoLuongTon = obj.SoLuongTon;
                this.objSach.MoTa = obj.MoTa;
                this.objSach.AnhBia = obj.AnhBia;
            }
        },

        // Thực hiện thao tác thêm hoặc chỉnh sửa thông tin
        saveUpdateAction() {
            if (!this.objSach.TenSach || !this.objSach.MaTacGia || !this.objSach.MaTheLoai || !this.objSach.GiaBan || !this.objSach.AnhBia) {
                this.errorMessage = "Vui lòng điền đầy đủ thông tin.";
                this.colorMessage = "red";
                return;
            }
            if (this.objSach.MaSach == 0) {
                axios.post('/Sach',
                    {
                        TenSach: this.objSach.TenSach,
                        MaTacGia: this.objSach.MaTacGia,
                        MaTheLoai: this.objSach.MaTheLoai,
                        SoLuongTon: this.objSach.SoLuongTon,
                        GiaBan: this.objSach.GiaBan,
                        AnhBia: this.objSach.AnhBia
                    })
                    .then((response) => {
                        this.showDialogUpdate = false;
                        this.getSach();
                        this.errorMessage = response.data.message;
                        this.colorMessage = "blue";
                    })
                    .catch((error) => {
                        this.errorMessage = error.response.data.message;
                        this.colorMessage = "red";
                        this.showDialogUpdate = false;
                    });
            } else {
                const payload = {
                    MaSach: this.objSach.MaSach,
                    TenSach: this.objSach.TenSach,
                    MaTacGia: this.objSach.MaTacGia,
                    MaTheLoai: this.objSach.MaTheLoai,
                    SoLuongTon: this.objSach.SoLuongTon,
                    GiaBan: this.objSach.GiaBan,
                    AnhBia: this.objSach.AnhBia
                };

                // Kiểm tra dữ liệu trước khi gửi
                console.log("Dữ liệu gửi đi:", payload);

                axios.put('/Sach', payload)
                    .then((response) => {
                        this.showDialogUpdate = false;
                        this.getSach();
                        this.errorMessage = response.data.message;
                        this.colorMessage = "blue";
                    })
                    .catch((error) => {
                        this.errorMessage = error?.response?.data?.message || "Lỗi không xác định!";
                        this.colorMessage = "red";
                        this.showDialogUpdate = false;
                    });
            }
        },

        // Hiển thị hộp thoại Confirm trước khi xoá
        showDialogDeleteConfirm(obj) {
            this.objSach.MaSach = obj.MaSach;
            this.showDialogDelete = true;
        },

        // Xoá dữ liệu
        deleteAction() {
            axios.delete(`/Sach/${this.objSach.MaSach}`)
                .then((response) => {
                    this.showDialogDelete = false;
                    this.getSach();
                    console.log(response.data.message);
                })
                .catch((error) => {
                    console.error(error.response?.data?.message || "Lỗi không xác định");
                });

        }


    }
}
</script>