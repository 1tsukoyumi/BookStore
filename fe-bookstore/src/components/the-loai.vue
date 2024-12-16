<template>
    <div class="text-center my-3">
        <div class="mb-2"><b>DANH SÁCH THỂ LOẠI</b></div>
        <v-btn elevation="0" color="success" @click="openDialogUpdateTheLoai(null)">
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
                <th> Mã TL </th>
                <th class="text-left"> Tên thể loại </th>
                <th> Sửa </th>
                <th> Xoá </th>
            </tr>
        </thead>
        <tbody>
            <tr v-for="item in dataTheLoai" :key="item.maTL">
                <td>{{ item.MaTL }}</td>
                <td>{{ item.TenTheLoai }}</td>
                <td><v-icon @click="openDialogUpdateTheLoai(item)">mdi-pencil</v-icon></td>
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
                    <v-text-field v-model="objTheLoai.TenTheLoai" label="Tên thể loại" variant="outlined"></v-text-field>
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
    name: 'TheLoaiComponent',
    data: () => ({
        dataTheLoai: [],
        showDialogUpdate: false,
        showDialogDelete: false,
        dialogUpdateTitle: "",
        objTheLoai: {
            MaTL: 0,
            TenTheLoai: ""
        },
        errorMessage: "",
        colorMessage: "blue"
    }),
    mounted() {
        this.getTheLoai()
    },
    methods: {
        // Lấy danh sách thể loại
        getTheLoai() {
            axios.get('/TheLoai', {})
                .then((response) => { this.dataTheLoai = [...response.data.data] })
                .catch((error) => { console.log(error); });
        },

        // Mở hộp thoại thêm hoặc sửa thông tin thể loại
        openDialogUpdateTheLoai(obj) {
            this.showDialogUpdate = true;
            if (obj == null) {
                this.dialogUpdateTitle = "Thêm mới thể loại"
                this.objTheLoai.MaTL = 0;
                this.objTheLoai.TenTheLoai = "";
            }
            else {
                this.dialogUpdateTitle = "Chỉnh sửa thông tin thể loại"
                this.objTheLoai.MaTL = obj.MaTL;
                this.objTheLoai.TenTheLoai = obj.TenTheLoai;
            }
        },

        // Thực hiện thao tác thêm hoặc chỉnh sửa thông tin
        saveUpdateAction() {
            if (this.objTheLoai.TenTheLoai == "")
                return;

            axios.post('/TheLoai/update',
                {
                    MaTL: this.objTheLoai.MaTL,
                    TenTheLoai: this.objTheLoai.TenTheLoai
                })
                .then((response) => {
                    this.showDialogUpdate = false;
                    this.getTheLoai();
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
            console.log("truoc khi mo hop thoai",this.objTheLoai)
            // Lưu giữ thông tin mã thể loại cần xoá
            this.objTheLoai.MaTL = obj.MaTL;
            this.objTheLoai.TenTheLoai = obj.TenTheLoai;
           
            this.showDialogDelete = true;
             console.log("sau khi mo hop thoai",this.objTheLoai)
        },

        // Xoá dữ liệu
        deleteAction() {
            axios.post('/TheLoai/delete',
                {
                    MaTL: this.objTheLoai.MaTL
                })
                .then((response) => {
                    this.getTheLoai();
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