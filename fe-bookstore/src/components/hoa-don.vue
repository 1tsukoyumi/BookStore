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

    <v-table style="width: 400px" class="mx-auto">
        <thead>
            <tr>
                <th> Mã HD </th>
                <th class="text-left"> Tên hóa đơn </th>
                <th> Sửa </th>
                <th> Xoá </th>
            </tr>
        </thead>
        <tbody>
            <tr v-for="item in dataHoaDon" :key="item.maHD">
                <td>{{ item.MaHD }}</td>
                <td>{{ item.TenHoaDon }}</td>
                <td><v-icon @click="openDialogUpdateHoaDon(item)">mdi-pencil</v-icon></td>
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
                    <v-text-field v-model="objHoaDon.TenHoaDon" label="Tên hóa đơn" variant="outlined"></v-text-field>
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
    name: 'HoaDonComponent',
    data: () => ({
        dataHoaDon: [],
        showDialogUpdate: false,
        showDialogDelete: false,
        dialogUpdateTitle: "",
        objHoaDon: {
            MaHD: 0,
            TenHoaDon: ""
        },
        errorMessage: "",
        colorMessage: "blue"
    }),
    mounted() {
        this.getHoaDon()
    },
    methods: {
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
                this.dialogUpdateTitle = "Thêm mới hóa đơn"
                this.objHoaDon.MaHD = 0;
                this.objHoaDon.TenHoaDon = "";
            }
            else {
                this.dialogUpdateTitle = "Chỉnh sửa thông tin hóa đơn"
                this.objHoaDon.MaHD = obj.MaHD;
                this.objHoaDon.TenHoaDon = obj.TenHoaDon;
            }
        },

        // Thực hiện thao tác thêm hoặc chỉnh sửa thông tin
        saveUpdateAction() {
            if (this.objHoaDon.TenHoaDon == "")
                return;

            axios.post('/HoaDon/update',
                {
                    MaHD: this.objHoaDon.MaHD,
                    TenHoaDon: this.objHoaDon.TenHoaDon
                })
                .then((response) => {
                    this.showDialogUpdate = false;
                    this.getHoaDon();
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