package universalFuncs

import (
	"context"
	metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
	"k8s.io/client-go/kubernetes"
	"log"
	"strings"
)

// CheckCubeUniverseComponent 检测CubeUniverse组件的情况
func CheckCubeUniverseComponent(clientSet *kubernetes.Clientset) (bool, bool, bool) {
	pods, _ := clientSet.CoreV1().Pods("cubeuniverse").List(context.TODO(), metav1.ListOptions{})
	var operator, dashboard, controlBackend bool
	for _, pod := range pods.Items {
		if strings.Index(pod.Name, "operator") != -1 && pod.Status.Phase == "Running" {
			operator = true
		} else if strings.Index(pod.Name, "dashboard") != -1 && pod.Status.Phase == "Running" {
			dashboard = true
		} else if strings.Index(pod.Name, "controlBackend") != -1 && pod.Status.Phase == "Running" {
			controlBackend = true
		}
	}
	if !(operator && dashboard && controlBackend) {
		log.Printf("CubeUniverse自检：\noperator：%t, dashboard: %t, controlBackend: %t", operator, dashboard, controlBackend)
	}
	return operator, dashboard, controlBackend
}
