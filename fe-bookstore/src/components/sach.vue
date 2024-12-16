<template>
    <div class="text-center my-3">
        <div class="mb-2"><b>DANH SÁCH SẢN PHẨM</b></div>
        <v-btn elevation="0" color="success" @click="openDialogUpdateSach(null)">
            <v-icon class="mr-2">mdi-plus-circle</v-icon>
            Thêm mới
        </v-btn>
    </div>

    <div v-if="errorMessage != ''" class="mt-2 mb-2 text-center" :style="{ color: colorMessage }">
        <b>{{ errorMessage }}</b>
    </div>

    <v-table style="width: 400px" class="mx-auto">
        <thead>
            <tr>
                <th> Mã sách </th>
                <th class="text-left"> Tên sách </th>
                <th class="text-left"> sách </th>
                <th class="text-left"> Tác giả </th>
                <th class="text-left"> Số lượng tồn </th>
                <th class="text-left"> Giá bán </th>
                <th class="text-left"> Ảnh bìa </th>
                <th> Sửa </th>
                <th> Xoá </th>
            </tr>
        </thead>
        <tbody>
            <tr v-for="item in dataSach" :key="item.maTL">
                <td>{{ item.MaTL }}</td>
                <td>{{ item.TenSach }}</td>
                <td><v-icon @click="openDialogUpdateSach(item)">mdi-pencil</v-icon></td>
                <td><v-icon @click="showDialogDeleteConfirm(item)">mdi-delete</v-icon></td>
            </tr>
        </tbody>
    </v-table>

    <!-- Hộp thoại Thêm, sửa dữ liệu -->
    <v-dialog width="400" scrollable v-model="showDialogUpdate">
        <template v-slot:default="{ isActive }">
            <v-card prepend-icon="mdi-earth" :title="dialogUpdateTitle">
                <v-divider class="mb-3"></v-divider>

                <v-card-text class="px-4">
                    <v-text-field v-model="objSach.TenSach" label="Tên sách" variant="outlined"></v-text-field>
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
            MaTL: 0,
            TenSach: ""
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
                this.dialogUpdateTitle = "Thêm mới sách"
                this.objSach.MaTL = 0;
                this.objSach.TenSach = "";
            }
            else {
                this.dialogUpdateTitle = "Chỉnh sửa thông tin sách"
                this.objSach.MaTL = obj.MaTL;
                this.objSach.TenSach = obj.TenSach;
            }
        },

        // Thực hiện thao tác thêm hoặc chỉnh sửa thông tin
        saveUpdateAction() {
            if (this.objSach.TenSach == "")
                return;

            axios.post('/Sach/update',
                {
                    MaTL: this.objSach.MaTL,
                    TenSach: this.objSach.TenSach
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
        },

        // Hiển thị hộp thoại Confirm trước khi xoá
        showDialogDeleteConfirm(obj) {
            console.log("truoc khi mo hop thoai",this.objSach)
            // Lưu giữ thông tin mã sách cần xoá
            this.objSach.MaTL = obj.MaTL;
            this.objSach.TenSach = obj.TenSach;
           
            this.showDialogDelete = true;
             console.log("sau khi mo hop thoai",this.objSach)
        },

        // Xoá dữ liệu
        deleteAction() {
            axios.post('/Sach/delete',
                {
                    MaTL: this.objSach.MaTL
                })
                .then((response) => {
                    this.getSach();
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