<template>
    <div class="text-center my-3">
        <div class="mb-2"><b>DANH SÁCH TÁC GIẢ</b></div>
        <v-btn elevation="0" color="success" @click="openDialogUpdateTacGia(null)">
            Thêm mới
        </v-btn>
    </div>

    <div v-if="errorMessage != ''" class="mt-2 mb-2 text-center" :style="{ color: colorMessage }">
        <b>{{ errorMessage }}</b>
    </div>

    <v-table style="width: 400px" class="mx-auto">
        <thead>
            <tr>
                <th> Mã TG </th>
                <th class="text-left"> Tên tác giả </th>
                <th> Sửa </th>
                <th> Xoá </th>
            </tr>
        </thead>
        <tbody>
            <tr v-for="item in dataTacGia" :key="item.MaTacGia">
                <td>{{ item.MaTacGia }}</td>
                <td>{{ item.TenTacGia }}</td>
                <td><v-icon style="background-color: greenyellow;" @click="openDialogUpdateTacGia(item)">mdi-pencil</v-icon></td>
                <td><v-icon style="background-color: red;" @click="showDialogDeleteConfirm(item)">mdi-delete</v-icon></td>
            </tr>
        </tbody>
    </v-table>

    <!-- Hộp thoại Thêm, sửa dữ liệu -->
    <v-dialog width="50%" scrollable v-model="showDialogUpdate">
        <template v-slot:default="{ isActive }">
            <v-card prepend-icon="mdi-earth" :title="dialogUpdateTitle">
                <v-divider class="mb-3"></v-divider>

                <v-card-text class="px-4">
                    <v-text-field v-model="objTacGia.TenTacGia" label="Tên tác giả" variant="outlined"></v-text-field>
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
            <v-card-tiTGe class="headline">Xác nhận xoá</v-card-tiTGe>
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
    name: 'TacGiaComponent',
    data: () => ({
        dataTacGia: [],
        showDialogUpdate: false,
        showDialogDelete: false,
        dialogUpdateTiTGe: "",
        objTacGia: {
            MaTacGia: 0,
            TenTacGia: ""
        },
        errorMessage: "",
        colorMessage: "blue"
    }),
    mounted() {
        this.getTacGia()
    },
    methods: {
        // Lấy danh sách tác giả
        getTacGia() {
            axios.get('/TacGia', {})
                .then((response) => { this.dataTacGia = [...response.data.data] })
                .catch((error) => { console.log(error); });
        },

        // Mở hộp thoại thêm hoặc sửa thông tin tác giả
        openDialogUpdateTacGia(obj) {
            this.showDialogUpdate = true;
            if (obj == null) {
                this.dialogUpdateTitle = "Thêm mới tác giả"
                this.objTacGia.MaTacGia = 0;
                this.objTacGia.TenTacGia = "";
            }
            else {
                this.dialogUpdateTitle = "Chỉnh sửa thông tin tác giả"
                this.objTacGia.MaTacGia = obj.MaTacGia;
                this.objTacGia.TenTacGia = obj.TenTacGia;
            }
        },

        // Thực hiện thao tác thêm hoặc chỉnh sửa thông tin
        saveUpdateAction() {
            if (this.objTacGia.TenTacGia == "")
                return;
            if (this.objTacGia.MaTacGia != 0){
                axios.put('/Tacgia/update',
                {
                    MaTacGia: this.objTacGia.MaTacGia,
                    TenTacGia: this.objTacGia.TenTacGia,
                })
                .then((response) => {
                    this.showDialogUpdate = false;
                    this.getTacGia();
                    this.errorMessage = response.data.message;
                    this.colorMessage = "blue";
                })
                .catch((error) => {
                    this.errorMessage = error.response.data.message;
                    this.colorMessage = "red";
                    this.showDialogUpdate = false;
                });
            }else{
                axios.post('/TacGia',
                {
                    MaTacGia: this.objTacGia.MaTacGia,
                    TenTacGia: this.objTacGia.TenTacGia,
                })
                .then((response) => {
                    this.showDialogUpdate = false;
                    this.getTacGia();
                    this.errorMessage = response.data.message;
                    this.colorMessage = "blue";
                })
                .catch((error) => {
                    this.errorMessage = error.response.data.message;
                    this.colorMessage = "red";
                    this.showDialogUpdate = false;
                });
            }
        },

        // Hiển thị hộp thoại Confirm trước khi xoá
        showDialogDeleteConfirm(obj) {
            this.objTacGia.MaTacGia = obj.MaTacGia;
            this.objTacGia.TenTacGia = obj.TenTacGia;
            this.showDialogDelete = true;
        },

        // Xoá dữ liệu
        deleteAction() {
            axios.delete(`/Tacgia/${this.objTacGia.MaTacGia}`,
                {
                    MaTacGia: this.objTacGia.MaTacGia
                })
                .then((response) => {
                    this.getTacGia();
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